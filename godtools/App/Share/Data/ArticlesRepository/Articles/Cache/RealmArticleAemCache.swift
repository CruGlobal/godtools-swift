//
//  RealmArticleAemCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/2/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RequestOperation
import RepositorySync

final class RealmArticleAemCache: ArticleAemCacheInterface {
    
    typealias AemUri = String
    
    private let webArchiveFileCache: ArticleAemWebArchiveFileCache
    private let persistence: RealmRepositorySyncPersistence<ArticleAemData, ArticleAemData, RealmArticleAemData>
    private let articleWebArchiver: ArticleWebArchiverInterface
    private let realmDataWrite: RealmDataWrite
    
    init(
        webArchiveFileCache: ArticleAemWebArchiveFileCache,
        persistence: RealmRepositorySyncPersistence<ArticleAemData, ArticleAemData, RealmArticleAemData>,
        articleWebArchiver: ArticleWebArchiverInterface,
        realmDataWrite: RealmDataWrite
    ) {
        
        self.webArchiveFileCache = webArchiveFileCache
        self.persistence = persistence
        self.articleWebArchiver = articleWebArchiver
        self.realmDataWrite = realmDataWrite
    }
}

extension RealmArticleAemCache {
    
    func getArticleAemDataObjects() async throws -> [ArticleAemData] {
        return try await persistence.getDataModels()
    }
    
    func getAemCacheObject(aemUri: String) async throws -> ArticleAemCacheObject? {
        
        let realm: Realm = try persistence.database.openRealm()
        
        return try await getAemCacheObject(aemUri: aemUri, realm: realm)
    }
    
    func getAemCacheObjects(aemUris: [String]) async throws -> [ArticleAemCacheObject] {
        
        let realm: Realm = try persistence.database.openRealm()
        
        return try await getAemCacheObjects(aemUris: aemUris, realm: realm)
    }
    
    private func getAemCacheObjects(aemUris: [String], realm: Realm) async throws -> [ArticleAemCacheObject] {
        
        var aemCacheObjects: [ArticleAemCacheObject] = Array()
        
        for aemUri in aemUris {
            
            let aemCacheObject: ArticleAemCacheObject? = try await self.getAemCacheObject(
                aemUri: aemUri,
                realm: realm
            )
            
            guard let object = aemCacheObject else {
                continue
            }
            
            aemCacheObjects.append(object)
        }
        
        return aemCacheObjects
    }

    private func getAemCacheObject(aemUri: String, realm: Realm) async throws -> ArticleAemCacheObject? {
        
        guard let realmAemData = realm.object(ofType: RealmArticleAemData.self, forPrimaryKey: aemUri) else {
            return nil
        }
        
        let articleAemWebArchive = ArticleAemWebArchive(filename: realmAemData.webArchiveFilename)
        
        let url: URL = try await webArchiveFileCache.fileCache.getFile(location: articleAemWebArchive.location)
        
        let aemData = realmAemData.toModel()
        
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
     
        let realm: Realm = try persistence.database.openRealm()
        
        let aemDataObjectsThatNeedDownloading: ArticleAemDataObjectsThatNeedDownloading = try await filterAemDataObjectsThatNeedDownloaded(
            aemDataObjects: aemDataObjects,
            realm: realm
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
    
    private func filterAemDataObjectsThatNeedDownloaded(
        aemDataObjects: [ArticleAemData],
        realm: Realm
    ) async throws -> ArticleAemDataObjectsThatNeedDownloading {
                
        var aemDataDictionary: [AemUri: ArticleAemData] = Dictionary()
        var webArchiveUrls: [WebArchiveUrl] = Array()
        
        for aemData in aemDataObjects {
            
            guard let urlString = aemData.webUrl, let webUrl = URL(string: urlString) else {
                continue
            }
            
            let dataIsNotCached: Bool
            let uuidChanged: Bool
            
            if let aemCacheObject = try await getAemCacheObject(aemUri: aemData.aemUri, realm: realm),
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
        
        return try await withCheckedThrowingContinuation { continuation in
            
            storeAemCacheArchivedObjectsWithCompletion(aemCacheArchivedObjects: aemCacheArchivedObjects) { errors in
                
                if let error = errors.first {
                    continuation.resume(throwing: error)
                }
                else {
                    continuation.resume(returning: Void())
                }
            }
        }
    }
    
    private func storeAemCacheArchivedObjectsWithCompletion(
        aemCacheArchivedObjects: [ArticleAemCacheArchivedObject],
        completion: @escaping ((_ errors: [Error]) -> Void)
    ) {
        
        realmDataWrite.serialAsync { result in
            
            var errors: [Error] = Array()
            
            switch result {
            
            case .success(let realm):
                          
                do {
                    
                    var realmDataObjectsToStore: [RealmArticleAemData] = Array()
                    
                    for archivedObject in aemCacheArchivedObjects {
                        
                        let aemData: ArticleAemData = archivedObject.aemData
                        let existingRealmData: RealmArticleAemData? = realm.object(ofType: RealmArticleAemData.self, forPrimaryKey: aemData.aemUri)
                        
                        let realmDataToStore: RealmArticleAemData = RealmArticleAemData()
                        let webArchiveFilename: String
                                                                        
                        if let existingRealmData = existingRealmData {
                            
                            webArchiveFilename = existingRealmData.webArchiveFilename
                            
                            Task { [weak self] in
                                
                                await self?.removeWebArchivePlistData(
                                    webArchiveFilename: webArchiveFilename
                                )
                            }
                        }
                        else {
                            
                            webArchiveFilename = UUID().uuidString
                        }
                        
                        realmDataToStore.mapFrom(model: archivedObject.aemData)
                        realmDataToStore.webArchiveFilename = webArchiveFilename
                        
                        Task { [weak self] in
                            
                            await self?.storeWebArchivePlistData(
                                webArchiveFilename: webArchiveFilename,
                                webArchivePlistData: archivedObject.webArchivePlistData
                            )
                        }
                        
                        realmDataObjectsToStore.append(realmDataToStore)
                    }
                    
                    if !realmDataObjectsToStore.isEmpty {
                        try realm.write {
                            realm.add(realmDataObjectsToStore, update: .modified)
                        }
                    }
                }
                catch let error {
                    errors.append(error)
                }
                
            case .failure(let error):
                errors.append(error)
                
            }//end switch
            
            completion(errors)
            
        }//end serialAsync
    }
    
    private func storeWebArchivePlistData(webArchiveFilename: String, webArchivePlistData: Data) async {
        
        do {
            
            _ = try await webArchiveFileCache.fileCache.storeFile(
                location: ArticleAemWebArchive(filename: webArchiveFilename).location,
                data: webArchivePlistData
            )
        }
        catch _ {
            
        }
        
        
    }
    
    private func removeWebArchivePlistData(webArchiveFilename: String) async {
        
        do {
            
            try await webArchiveFileCache.fileCache.removeFile(
                location: ArticleAemWebArchive(filename: webArchiveFilename).location
            )
        }
        catch _ {
            
        }
    }
}
