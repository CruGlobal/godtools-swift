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

class ArticleAemCache {
    
    typealias AemUri = String
    
    private let fileCache: ArticleAemWebArchiveFileCache = ArticleAemWebArchiveFileCache()
    private let realmDatabase: RealmDatabase
    private let articleWebArchiver: ArticleWebArchiver
    
    init(realmDatabase: RealmDatabase, articleWebArchiver: ArticleWebArchiver) {
        
        self.realmDatabase = realmDatabase
        self.articleWebArchiver = articleWebArchiver
    }
    
    func getAemCacheObjectsOnBackgroundThread(aemUris: [String], completion: @escaping ((_ aemCacheObjects: [ArticleAemCacheObject]) -> Void)) {
        
        guard aemUris.count > 0 else {
            completion([])
            return
        }
        
        realmDatabase.background { (realm: Realm) in
            
            let aemCacheObjects: [ArticleAemCacheObject] = aemUris.compactMap({
                self.getAemCacheObject(realm: realm, aemUri: $0)
            })
            
            completion(aemCacheObjects)
        }
    }
    
    func getAemCacheObject(aemUri: String) -> ArticleAemCacheObject? {
        
        let realm: Realm = realmDatabase.openRealm()
        
        return getAemCacheObject(realm: realm, aemUri: aemUri)
    }

    private func getAemCacheObject(realm: Realm, aemUri: String) -> ArticleAemCacheObject? {
        
        guard let realmAemData = realm.object(ofType: RealmArticleAemData.self, forPrimaryKey: aemUri) else {
            return nil
        }
        
        let cacheLocation = ArticleAemWebArchiveFileCacheLocation(filename: realmAemData.webArchiveFilename)
        
        let cacheResult: Result<URL, Error> = fileCache.getFile(location: cacheLocation)
        
        switch cacheResult {
        case .success(let url):
            
            let aemData = ArticleAemData(realmModel: realmAemData)
            let aemCacheObject = ArticleAemCacheObject(aemUri: aemUri, aemData: aemData, webArchiveFileUrl: url, fetchWebArchiveFileUrlError: nil)
            
            return aemCacheObject
            
        case .failure(let error):
            
            let aemData = ArticleAemData(realmModel: realmAemData)
            let aemCacheObject = ArticleAemCacheObject(aemUri: aemUri, aemData: aemData, webArchiveFileUrl: nil, fetchWebArchiveFileUrlError: error)
            
            return aemCacheObject
        }
    }
    
    func storeAemDataObjectsPublisher(aemDataObjects: [ArticleAemData], sendRequestPriority: SendRequestPriority) -> AnyPublisher<ArticleAemCacheResult, Never> {
        
        return filterAemDataObjectsThatNeedDownloadedPublisher(aemDataObjects: aemDataObjects)
            .flatMap({ (filteredData: ArticleAemDataObjectsThatNeedDownloading) -> AnyPublisher<(filteredData: ArticleAemDataObjectsThatNeedDownloading, archiverResult: ArticleWebArchiverResult), Never> in
                
                return self.articleWebArchiver
                    .archivePublisher(webArchiveUrls: filteredData.webArchiveUrls, sendRequestPriority: sendRequestPriority)
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
                
                do {
                    try realm.write {
                        realm.add(realmDataObjectsToStore, update: .modified)
                    }
                }
                catch let error {

                }
                
                let result = ArticleAemCacheResult(
                    numberOfArchivedObjects: aemCacheArchivedObjects.count,
                    cacheErrorData: cacheErrorData
                )
                
                promise(.success(result))
                
            }//end realmDatabase.background
        }
        .eraseToAnyPublisher()
    }
    
    private func storeWebArchivePlistData(webArchiveFilename: String, webArchivePlistData: Data) -> ArticleAemCacheError? {
        
        let cacheFileResult: Result<URL, Error> = fileCache.storeFile(
            location: ArticleAemWebArchiveFileCacheLocation(filename: webArchiveFilename),
            data: webArchivePlistData
        )
        
        switch cacheFileResult {
        case .success( _):
            return nil
        case .failure(let error):
            return .failedToCacheWebArchivePlistData(error: error)
        }
    }
    
    private func removeWebArchivePlistData(webArchiveFilename: String) -> ArticleAemCacheError? {
        if let error = fileCache.removeFile(location: ArticleAemWebArchiveFileCacheLocation(filename: webArchiveFilename)) {
            return .failedToRemoveWebArchivePlistData(error: error)
        }
        return nil
    }
}
