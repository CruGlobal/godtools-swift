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

    func getArticleAemDataObjects() async throws -> [ArticleAemData] {

        let objects: [SwiftArticleAemData] = try SwiftDataRead().objects(context: modelContext, query: nil)

        return objects.map { $0.toModel() }
    }

    func getAemCacheObject(aemUri: String) async throws -> ArticleAemCacheObject? {

        return try getAemCacheObject(aemUri: aemUri, swiftDataRead: SwiftDataRead())
    }

    func getAemCacheObjects(aemUris: [String]) async throws -> [ArticleAemCacheObject] {

        let swiftDataRead = SwiftDataRead()

        let cachedObjects: [ArticleAemCacheObject] = try aemUris.compactMap { (aemUri: String) in
            try getAemCacheObject(aemUri: aemUri, swiftDataRead: swiftDataRead)
        }

        return cachedObjects
    }

    private func getAemCacheObject(aemUri: String, swiftDataRead: SwiftDataRead) throws -> ArticleAemCacheObject? {

        let aemDataObject: SwiftArticleAemData? = try swiftDataRead.object(context: modelContext, id: aemUri)

        guard let aemDataObject = aemDataObject else {
            return nil
        }

        let articleAemWebArchive = ArticleAemWebArchive(filename: aemDataObject.webArchiveFilename)

        let url: URL = try webArchiveFileCache.fileCache.getFile(location: articleAemWebArchive.location)

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

        let aemDataObjectsThatNeedDownloading: ArticleAemDataObjectsThatNeedDownloading = try filterAemDataObjectsThatNeedDownloaded(
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

        try storeAemCacheArchivedObjects(aemCacheArchivedObjects: aemCacheArchivedObjects)

        return webArchives
    }

    private func filterAemDataObjectsThatNeedDownloaded(aemDataObjects: [ArticleAemData]) throws -> ArticleAemDataObjectsThatNeedDownloading {

        let swiftDataRead = SwiftDataRead()

        var aemDataDictionary: [AemUri: ArticleAemData] = Dictionary()
        var webArchiveUrls: [WebArchiveUrl] = Array()

        for aemData in aemDataObjects {

            guard let urlString = aemData.webUrl, let webUrl = URL(string: urlString) else {
                continue
            }

            let dataIsNotCached: Bool
            let uuidChanged: Bool

            if let aemCacheObject = try getAemCacheObject(aemUri: aemData.aemUri, swiftDataRead: swiftDataRead),
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

    private func storeAemCacheArchivedObjects(aemCacheArchivedObjects: [ArticleAemCacheArchivedObject]) throws {

        let swiftDataRead = SwiftDataRead()

        var aemDataObjectsToStore: [SwiftArticleAemData] = Array()

        for archivedObject in aemCacheArchivedObjects {

            let aemData: ArticleAemData = archivedObject.aemData
            let existingAemDataObject: SwiftArticleAemData? = try swiftDataRead.object(context: modelContext, id: aemData.aemUri)

            let aemDataObjectToStore: SwiftArticleAemData = SwiftArticleAemData()
            let webArchiveFilename: String

            if let existingAemDataObject = existingAemDataObject {

                webArchiveFilename = existingAemDataObject.webArchiveFilename

                try removeWebArchivePlistData(
                    webArchiveFilename: webArchiveFilename
                )
            }
            else {

                webArchiveFilename = UUID().uuidString
            }

            aemDataObjectToStore.mapFrom(model: aemData)
            aemDataObjectToStore.webArchiveFilename = webArchiveFilename

            try storeWebArchivePlistData(
                webArchiveFilename: webArchiveFilename,
                webArchivePlistData: archivedObject.webArchivePlistData
            )

            aemDataObjectsToStore.append(aemDataObjectToStore)
        }

        modelContext.insertObjects(objects: aemDataObjectsToStore)

        try modelContext.saveIfHasChanges()
    }

    private func storeWebArchivePlistData(webArchiveFilename: String, webArchivePlistData: Data) throws {

        _ = try webArchiveFileCache.fileCache.storeFile(
            location: ArticleAemWebArchive(filename: webArchiveFilename).location,
            data: webArchivePlistData
        )
    }

    private func removeWebArchivePlistData(webArchiveFilename: String) throws {

        try webArchiveFileCache.fileCache.removeFile(
            location: ArticleAemWebArchive(filename: webArchiveFilename).location
        )
    }
}
