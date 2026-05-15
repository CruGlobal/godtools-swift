//
//  ArticleAemCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/2/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RequestOperation
import RepositorySync

final class ArticleAemCache {
    
    typealias AemUri = String
    
    private let fileCache: ArticleAemWebArchiveFileCache = ArticleAemWebArchiveFileCache()
    private let persistence: any Persistence<ArticleAemData, ArticleAemData>
    private let articleWebArchiver: ArticleWebArchiver
    
    init(persistence: any Persistence<ArticleAemData, ArticleAemData>, articleWebArchiver: ArticleWebArchiver) {
        
        self.persistence = persistence
        self.articleWebArchiver = articleWebArchiver
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<ArticleAemData, ArticleAemData, SwiftArticleAemData>? {
        return persistence as? SwiftRepositorySyncPersistence<ArticleAemData, ArticleAemData, SwiftArticleAemData>
    }
    
    private var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<ArticleAemData, ArticleAemData, RealmArticleAemData>? {
        return persistence as? RealmRepositorySyncPersistence<ArticleAemData, ArticleAemData, RealmArticleAemData>
    }
}

extension ArticleAemCache {
    
    func getAemCacheObject(aemUri: String) throws -> ArticleAemCacheObject? {
        
        guard let realmDatabase = realmDatabase else {
            return nil
        }
        
        let realm: Realm = try realmDatabase.openRealm()
        
        return try getAemCacheObject(aemUri: aemUri, realm: realm)
    }
    
    func getAemCacheObjects(aemUris: [String]) throws -> [ArticleAemCacheObject] {
        
        guard let realmDatabase = realmDatabase else {
            return Array()
        }
        
        let realm: Realm = try realmDatabase.openRealm()
        
        return try getAemCacheObjects(aemUris: aemUris, realm: realm)
    }
    
    private func getAemCacheObjects(aemUris: [String], realm: Realm) throws -> [ArticleAemCacheObject] {
        
        let cachedObjects: [ArticleAemCacheObject] = try aemUris.compactMap { (aemUri: String) in
            try getAemCacheObject(aemUri: aemUri, realm: realm)
        }
        
        return cachedObjects
    }

    private func getAemCacheObject(aemUri: String, realm: Realm) throws -> ArticleAemCacheObject? {
        
        guard let realmAemData = realm.object(ofType: RealmArticleAemData.self, forPrimaryKey: aemUri) else {
            return nil
        }
        
        let articleAemWebArchive = ArticleAemWebArchive(filename: realmAemData.webArchiveFilename)
        
        let url: URL = try fileCache.getFile(location: articleAemWebArchive.location)
        
        let aemData = realmAemData.toModel()
        
        return ArticleAemCacheObject(
            aemUri: aemUri,
            aemData: aemData,
            webArchiveFileUrl: url
        )
    }
    
    func storeAemDataObjects(aemDataObjects: [ArticleAemData], requestPriority: RequestPriority) async throws -> ArticleWebArchiverResult {
     
        guard let realmDatabase = realmDatabase else {
            throw NSError.errorWithDescription(description: "RealmDatabase is null.")
        }
        
        let realm: Realm = try realmDatabase.openRealm()
        
        let aemDataObjectsThatNeedDownloading: ArticleAemDataObjectsThatNeedDownloading = try filterAemDataObjectsThatNeedDownloaded(
            aemDataObjects: aemDataObjects,
            realm: realm
        )
        
        let webArchiverResults: ArticleWebArchiverResult = await articleWebArchiver.archive(
            webArchiveUrls: aemDataObjectsThatNeedDownloading.webArchiveUrls,
            requestPriority: requestPriority
        )
        
        var aemCacheArchivedObjects: [ArticleAemCacheArchivedObject] = Array()
        
        for webArchiveResult in webArchiverResults.archives {
            
            if let aemData = aemDataObjectsThatNeedDownloading.aemDataDictionary[webArchiveResult.webArchiveUrl.uuid] {
                
                let archivedObject = ArticleAemCacheArchivedObject(
                    aemData: aemData,
                    webArchivePlistData: webArchiveResult.webArchivePlistData
                )
                
                aemCacheArchivedObjects.append(archivedObject)
            }
        }
        
        try await storeAemCacheArchivedObjects(aemCacheArchivedObjects: aemCacheArchivedObjects)
        
        return webArchiverResults
    }
    
    private func filterAemDataObjectsThatNeedDownloaded(aemDataObjects: [ArticleAemData], realm: Realm) throws -> ArticleAemDataObjectsThatNeedDownloading {
                
        var aemDataDictionary: [AemUri: ArticleAemData] = Dictionary()
        var webArchiveUrls: [WebArchiveUrl] = Array()
        
        for aemData in aemDataObjects {
            
            guard let webUrl = URL(string: aemData.webUrl) else {
                continue
            }
            
            let dataIsNotCached: Bool
            let uuidChanged: Bool
            
            if let aemCacheObject = try getAemCacheObject(aemUri: aemData.aemUri, realm: realm),
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
    
    private func storeAemCacheArchivedObjectsWithCompletion(aemCacheArchivedObjects: [ArticleAemCacheArchivedObject], completion: @escaping ((_ errors: [Error]) -> Void)) {
        
        guard let realmDatabase = realmDatabase else {
            completion([])
            return
        }
        
        realmDatabase.write.serialAsync { result in
            
            var errors: [Error] = Array()
            
            switch result {
            
            case .success(let realm):
                          
                do {
                    
                    try realm.write {
                        
                        var realmDataObjectsToStore: [RealmArticleAemData] = Array()
                        
                        for archivedObject in aemCacheArchivedObjects {
                            
                            let aemData: ArticleAemData = archivedObject.aemData
                            let existingRealmData: RealmArticleAemData? = realm.object(ofType: RealmArticleAemData.self, forPrimaryKey: aemData.aemUri)
                            
                            let realmDataToStore: RealmArticleAemData
                            let webArchiveFilename: String
                                                                            
                            if let existingRealmData = existingRealmData {
                                
                                webArchiveFilename = existingRealmData.webArchiveFilename
                                
                                try self.removeWebArchivePlistData(
                                    webArchiveFilename: webArchiveFilename
                                )
                                
                                realmDataToStore = existingRealmData
                                realmDataToStore.mapFrom(model: archivedObject.aemData, ignorePrimaryKey: true)
                            }
                            else {
                                
                                webArchiveFilename = UUID().uuidString
                                
                                realmDataToStore = RealmArticleAemData()
                                realmDataToStore.mapFrom(model: archivedObject.aemData, ignorePrimaryKey: false)
                                realmDataToStore.webArchiveFilename = webArchiveFilename
                            }
                            
                            try self.storeWebArchivePlistData(
                                webArchiveFilename: webArchiveFilename,
                                webArchivePlistData: archivedObject.webArchivePlistData
                            )
                            
                            realmDataObjectsToStore.append(realmDataToStore)
                        }
                        
                        realm.add(realmDataObjectsToStore, update: .modified)
                    }
                }
                catch let error {
                    errors.append(error)
                }
                
            case .failure(let error):
                errors.append(error)
                
            }//end switch
            
            completion(errors)
            
        }//end realmDatabase.write.serialAsync
    }
    
    private func storeWebArchivePlistData(webArchiveFilename: String, webArchivePlistData: Data) throws {
        
        _ = try fileCache.storeFile(
            location: ArticleAemWebArchive(filename: webArchiveFilename).location,
            data: webArchivePlistData
        )
    }
    
    private func removeWebArchivePlistData(webArchiveFilename: String) throws {
        
        try fileCache.removeFile(
            location: ArticleAemWebArchive(filename: webArchiveFilename).location
        )
    }
}
