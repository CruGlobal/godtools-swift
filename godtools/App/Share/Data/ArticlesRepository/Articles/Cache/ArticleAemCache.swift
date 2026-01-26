//
//  ArticleAemCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/2/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine
import RequestOperation

class ArticleAemCache {
    
    typealias AemUri = String
    
    private let fileCache: ArticleAemWebArchiveFileCache = ArticleAemWebArchiveFileCache()
    private let realmDatabase: LegacyRealmDatabase
    private let articleWebArchiver: ArticleWebArchiver
    
    init(realmDatabase: LegacyRealmDatabase, articleWebArchiver: ArticleWebArchiver) {
        
        self.realmDatabase = realmDatabase
        self.articleWebArchiver = articleWebArchiver
    }
    
    func observeArticleAemCacheObjectsChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return realmDatabase.openRealm()
            .objects(RealmResource.self)
            .objectWillChange
            .eraseToAnyPublisher()
    }
    
    func getAemCacheObjectsPublisher(aemUris: [String]) -> AnyPublisher<[ArticleAemCacheObject], Never> {
        
        return Future() { promise in

            self.realmDatabase.background { realm in
                    
                let cachedObjects: [ArticleAemCacheObject] = aemUris.compactMap { (aemUri: String) in
                    self.getAemCacheObject(realm: realm, aemUri: aemUri)
                }
                
                promise(.success(cachedObjects))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getAemCacheObject(aemUri: String) -> ArticleAemCacheObject? {
        return getAemCacheObject(realm: realmDatabase.openRealm(), aemUri: aemUri)
    }
    
    private func getAemCacheObjects(aemUris: [String], realm: Realm) -> [ArticleAemCacheObject] {
        
        let cachedObjects: [ArticleAemCacheObject] = aemUris.compactMap { (aemUri: String) in
            self.getAemCacheObject(realm: realm, aemUri: aemUri)
        }
        
        return cachedObjects
    }

    private func getAemCacheObject(realm: Realm, aemUri: String) -> ArticleAemCacheObject? {
        
        guard let realmAemData = realm.object(ofType: RealmArticleAemData.self, forPrimaryKey: aemUri) else {
            return nil
        }
        
        let cacheLocation = ArticleAemWebArchiveFileCacheLocation(filename: realmAemData.webArchiveFilename)
        
        do {
            
            let url: URL = try fileCache.getFile(location: cacheLocation)
            
            let aemData = ArticleAemData(realmModel: realmAemData)
            let aemCacheObject = ArticleAemCacheObject(aemUri: aemUri, aemData: aemData, webArchiveFileUrl: url, fetchWebArchiveFileUrlError: nil)
            
            return aemCacheObject
        }
        catch let error {
            
            let aemData = ArticleAemData(realmModel: realmAemData)
            let aemCacheObject = ArticleAemCacheObject(aemUri: aemUri, aemData: aemData, webArchiveFileUrl: nil, fetchWebArchiveFileUrlError: error)
            
            return aemCacheObject
        }
    }
    
    func storeAemDataObjectsPublisher(aemDataObjects: [ArticleAemData], requestPriority: RequestPriority) -> AnyPublisher<ArticleAemCacheResult, Never> {
        
        return filterAemDataObjectsThatNeedDownloadedPublisher(aemDataObjects: aemDataObjects)
            .flatMap({ (filteredData: ArticleAemDataObjectsThatNeedDownloading) -> AnyPublisher<(filteredData: ArticleAemDataObjectsThatNeedDownloading, archiverResult: ArticleWebArchiverResult), Never> in
                
                return self.articleWebArchiver
                    .archivePublisher(webArchiveUrls: filteredData.webArchiveUrls, requestPriority: requestPriority)
                    .map { (archiverResult: ArticleWebArchiverResult) in
                        return (filteredData: filteredData, archiverResult: archiverResult)
                    }
                    .eraseToAnyPublisher()
            })
            .flatMap({ (filteredData: ArticleAemDataObjectsThatNeedDownloading, archiverResult: ArticleWebArchiverResult) -> AnyPublisher<ArticleAemCacheResult, Never> in
                
                guard archiverResult.successfulArchives.count > 0 else {
                    return Just(ArticleAemCacheResult.emptyResult())
                        .eraseToAnyPublisher()
                }
                
                var aemCacheArchivedObjects: [ArticleAemCacheArchivedObject] = Array()
                
                for webArchiveResult in archiverResult.successfulArchives {
                    
                    if let aemData = filteredData.aemDataDictionary[webArchiveResult.webArchiveUrl.uuid] {
                        
                        let archivedObject = ArticleAemCacheArchivedObject(
                            aemData: aemData,
                            webArchivePlistData: webArchiveResult.webArchivePlistData
                        )
                        
                        aemCacheArchivedObjects.append(archivedObject)
                    }
                }
                
                return self.storeAemCacheArchivedObjectsPublisher(aemCacheArchivedObjects: aemCacheArchivedObjects)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func filterAemDataObjectsThatNeedDownloadedPublisher(aemDataObjects: [ArticleAemData]) -> AnyPublisher<ArticleAemDataObjectsThatNeedDownloading, Never> {
        
        return Future() { promise in

            self.realmDatabase.background { realm in
                
                let filteredData: ArticleAemDataObjectsThatNeedDownloading = self.filterAemDataObjectsThatNeedDownloaded(
                    aemDataObjects: aemDataObjects,
                    realm: realm
                )
                
                promise(.success(filteredData))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func filterAemDataObjectsThatNeedDownloaded(aemDataObjects: [ArticleAemData], realm: Realm) -> ArticleAemDataObjectsThatNeedDownloading {
                
        var aemDataDictionary: [AemUri: ArticleAemData] = Dictionary()
        var webArchiveUrls: [WebArchiveUrl] = Array()
        
        for aemData in aemDataObjects {
            
            guard let webUrl = URL(string: aemData.webUrl) else {
                continue
            }
            
            let dataIsNotCached: Bool
            let uuidChanged: Bool
            
            if let aemCacheObject = getAemCacheObject(realm: realm, aemUri: aemData.aemUri),
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
    
    private func storeAemCacheArchivedObjectsPublisher(aemCacheArchivedObjects: [ArticleAemCacheArchivedObject]) -> AnyPublisher<ArticleAemCacheResult, Never> {
        
        return Future() { promise in

            self.realmDatabase.background { realm in
                
                var realmDataObjectsToStore: [RealmArticleAemData] = Array()
                var cacheErrorData: [ArticleAemCacheErrorData] = Array()
                
                let saveAemDataToRealmError: Error?
                
                do {
                    try realm.write {
                        
                        for archivedObject in aemCacheArchivedObjects {
                            
                            let aemData: ArticleAemData = archivedObject.aemData
                            let aemUri: String = aemData.aemUri
                            let existingRealmData: RealmArticleAemData? = realm.object(ofType: RealmArticleAemData.self, forPrimaryKey: aemData.aemUri)
                            
                            let realmDataToStore: RealmArticleAemData
                            let webArchiveFilename: String
                            
                            var aemCacheErrors: [ArticleAemCacheError] = Array()
                                                
                            if let existingRealmData = existingRealmData {
                                
                                webArchiveFilename = existingRealmData.webArchiveFilename
                                
                                if let removeWebArchiveError = self.removeWebArchivePlistData(webArchiveFilename: webArchiveFilename) {
                                    aemCacheErrors.append(removeWebArchiveError)
                                }
                                
                                realmDataToStore = existingRealmData
                                realmDataToStore.mapFrom(model: archivedObject.aemData, ignorePrimaryKey: true)
                            }
                            else {
                                
                                webArchiveFilename = UUID().uuidString
                                
                                realmDataToStore = RealmArticleAemData()
                                realmDataToStore.mapFrom(model: archivedObject.aemData, ignorePrimaryKey: false)
                                realmDataToStore.webArchiveFilename = webArchiveFilename
                            }
                            
                            if let storeWebArchiveError = self.storeWebArchivePlistData(
                                webArchiveFilename: webArchiveFilename,
                                webArchivePlistData: archivedObject.webArchivePlistData
                            ) {
                                aemCacheErrors.append(storeWebArchiveError)
                            }
                            
                            realmDataObjectsToStore.append(realmDataToStore)
                            
                            if aemCacheErrors.count > 0 {
                                cacheErrorData.append(ArticleAemCacheErrorData(aemUri: aemUri, cacheErrors: aemCacheErrors))
                            }
                        }
                        
                        realm.add(realmDataObjectsToStore, update: .modified)
                    }
                    
                    saveAemDataToRealmError = nil
                }
                catch let error {
                    
                    saveAemDataToRealmError = error
                }
                
                let result = ArticleAemCacheResult(
                    numberOfArchivedObjects: aemCacheArchivedObjects.count,
                    cacheErrorData: cacheErrorData,
                    saveAemDataToRealmError: saveAemDataToRealmError
                )
                
                promise(.success(result))
                
            }//end realmDatabase.background
        }
        .eraseToAnyPublisher()
    }
    
    private func storeWebArchivePlistData(webArchiveFilename: String, webArchivePlistData: Data) -> ArticleAemCacheError? {
        
        do {
            _ = try fileCache.storeFile(
                location: ArticleAemWebArchiveFileCacheLocation(filename: webArchiveFilename),
                data: webArchivePlistData
            )
            
            return nil
        }
        catch let error {
            
            return .failedToCacheWebArchivePlistData(error: error)
        }
    }
    
    private func removeWebArchivePlistData(webArchiveFilename: String) -> ArticleAemCacheError? {
        
        do {
            
            try fileCache.removeFile(
                location: ArticleAemWebArchiveFileCacheLocation(filename: webArchiveFilename)
            )
            
            return nil
        }
        catch let error {
            
            return .failedToRemoveWebArchivePlistData(error: error)
        }
    }
}
