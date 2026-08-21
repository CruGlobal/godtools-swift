//
//  ArticleAemCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import RequestOperation
import SwiftData

@available(iOS 17.4, *)
actor ArticleAemCache: ArticleAemCacheInterface, ModelActor {

    typealias AemUri = String

    private let webArchiveFileCache: ArticleAemWebArchiveFileCache
    private let articleWebArchiver: ArticleWebArchiverInterface

    let modelContainer: ModelContainer
    let modelExecutor: ModelExecutor

    init(
        container: ModelContainer,
        webArchiveFileCache: ArticleAemWebArchiveFileCache,
        articleWebArchiver: ArticleWebArchiverInterface
    ) {

        self.webArchiveFileCache = webArchiveFileCache
        self.articleWebArchiver = articleWebArchiver

        self.modelContainer = container
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(container))
    }

    func getArticleAemDataObjects() throws -> [ArticleAemData] {

        let objects: [SwiftArticleAemData] = try SwiftDataRead().objects(context: modelContext, query: nil)

        return objects.map { $0.toModel() }
    }

    func getAemCacheObject(aemUri: String) async throws -> ArticleAemCacheObject? {

        return try await getAemCacheObject(aemUri: aemUri, swiftDataRead: SwiftDataRead())
    }

    func getAemCacheObjects(aemUris: [String]) async throws -> [ArticleAemCacheObject] {

        let swiftDataRead = SwiftDataRead()
        
        return try await withThrowingTaskGroup(of: ArticleAemCacheObject?.self) { group in
            
            for aemUri in aemUris {
                
                group.addTask {
                    
                    return try await self.getAemCacheObject(aemUri: aemUri, swiftDataRead: swiftDataRead)
                }
            }
            
            var cachedObjects: [ArticleAemCacheObject] = Array()
            
            for try await article in group {
                
                guard let article = article else {
                    continue
                }
                
                cachedObjects.append(article)
            }

            return cachedObjects
        }
    }

    private func getAemCacheObject(aemUri: String, swiftDataRead: SwiftDataRead) async throws -> ArticleAemCacheObject? {

        let aemDataObject: SwiftArticleAemData? = try swiftDataRead.object(context: modelContext, id: aemUri)

        guard let aemDataObject = aemDataObject else {
            return nil
        }

        let articleAemWebArchive = ArticleAemWebArchive(filename: aemDataObject.webArchiveFilename)

        let url: URL = try await webArchiveFileCache.fileCache.getFile(location: articleAemWebArchive.location)

        let aemData: ArticleAemData = aemDataObject.toModel()

        return ArticleAemCacheObject(
            aemUri: aemUri,
            aemData: aemData,
            webArchiveFileUrl: url
        )
    }

    func storeAemDataObjects(
        aemDataObjects: [ArticleAemData],
        requestPriority: RequestPriority
    ) async throws -> [ArticleWebArchiveData] {

        let aemDataObjectsThatNeedDownloading: ArticleAemDataObjectsThatNeedDownloading = try await filterAemDataObjectsThatNeedDownloaded(
            aemDataObjects: aemDataObjects
        )

        let webArchives: [ArticleWebArchiveData] = await articleWebArchiver.archive(
            webArchiveUrls: aemDataObjectsThatNeedDownloading.webArchiveUrls,
            requestPriority: requestPriority
        )

        var aemCacheArchivedObjects: [ArticleAemCacheArchivedObject] = Array()

        for archive in webArchives {

            guard let plistData = archive.webArchivePlistData,
                  let aemData = aemDataObjectsThatNeedDownloading.aemDataDictionary[archive.webArchiveUrl.uuid] else {
                continue
            }

            let archivedObject = ArticleAemCacheArchivedObject(
                aemData: aemData,
                webArchivePlistData: plistData
            )

            aemCacheArchivedObjects.append(archivedObject)
        }

        try await storeAemCacheArchivedObjects(aemCacheArchivedObjects: aemCacheArchivedObjects)

        return webArchives
    }

    private func filterAemDataObjectsThatNeedDownloaded(aemDataObjects: [ArticleAemData]) async throws -> ArticleAemDataObjectsThatNeedDownloading {

        let swiftDataRead = SwiftDataRead()

        var aemDataDictionary: [AemUri: ArticleAemData] = Dictionary()
        var webArchiveUrls: [WebArchiveUrl] = Array()

        for aemData in aemDataObjects {

            guard let urlString = aemData.webUrl, let webUrl = URL(string: urlString) else {
                continue
            }

            let dataIsNotCached: Bool
            let uuidChanged: Bool

            if let aemCacheObject = try await getAemCacheObject(aemUri: aemData.aemUri, swiftDataRead: swiftDataRead),
               let cachedUUID = aemCacheObject.aemData.articleJcrContent?.uuid,
               let uuid = aemData.articleJcrContent?.uuid, !cachedUUID.isEmpty, !uuid.isEmpty {

                dataIsNotCached = false
                uuidChanged = cachedUUID != uuid
            }
            else {

                dataIsNotCached = true
                uuidChanged = false
            }

            if dataIsNotCached || uuidChanged {

                let webArchiveUrl = WebArchiveUrl(
                    webUrl: webUrl,
                    uuid: aemData.aemUri
                )

                aemDataDictionary[aemData.aemUri] = aemData

                webArchiveUrls.append(webArchiveUrl)
            }
        }

        return ArticleAemDataObjectsThatNeedDownloading(
            aemDataDictionary: aemDataDictionary,
            webArchiveUrls: webArchiveUrls
        )
    }

    private func storeAemCacheArchivedObjects(aemCacheArchivedObjects: [ArticleAemCacheArchivedObject]) async throws {

        let swiftDataRead = SwiftDataRead()

        var aemDataObjectsToStore: [SwiftArticleAemData] = Array()

        for archivedObject in aemCacheArchivedObjects {

            let aemData: ArticleAemData = archivedObject.aemData
            let existingAemDataObject: SwiftArticleAemData? = try swiftDataRead.object(context: modelContext, id: aemData.aemUri)

            let aemDataObjectToStore: SwiftArticleAemData = SwiftArticleAemData()
            let webArchiveFilename: String

            if let existingAemDataObject = existingAemDataObject {

                webArchiveFilename = existingAemDataObject.webArchiveFilename

                try await removeWebArchivePlistData(
                    webArchiveFilename: webArchiveFilename
                )
            }
            else {

                webArchiveFilename = UUID().uuidString
            }

            aemDataObjectToStore.mapFrom(model: aemData)
            aemDataObjectToStore.webArchiveFilename = webArchiveFilename

            try await storeWebArchivePlistData(
                webArchiveFilename: webArchiveFilename,
                webArchivePlistData: archivedObject.webArchivePlistData
            )

            aemDataObjectsToStore.append(aemDataObjectToStore)
        }

        modelContext.insertObjects(objects: aemDataObjectsToStore)

        try modelContext.saveIfHasChanges()
    }

    private func storeWebArchivePlistData(webArchiveFilename: String, webArchivePlistData: Data) async throws {

        _ = try await webArchiveFileCache.fileCache.storeFile(
            location: ArticleAemWebArchive(filename: webArchiveFilename).location,
            data: webArchivePlistData
        )
    }

    private func removeWebArchivePlistData(webArchiveFilename: String) async throws {

        try await webArchiveFileCache.fileCache.removeFile(
            location: ArticleAemWebArchive(filename: webArchiveFilename).location
        )
    }
}
