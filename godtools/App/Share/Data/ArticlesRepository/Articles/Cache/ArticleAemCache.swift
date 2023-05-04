//
//  ArticleAemCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/2/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ArticleAemCache {
    
    private let fileCache: ArticleAemWebArchiveFileCache = ArticleAemWebArchiveFileCache()
    private let realmDatabase: RealmDatabase
    private let webArchiveQueue: WebArchiveQueue
    
    init(realmDatabase: RealmDatabase, webArchiveQueue: WebArchiveQueue) {
        
        self.realmDatabase = realmDatabase
        self.webArchiveQueue = webArchiveQueue
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
    
    func getAemCacheObjectOnCurrentThread(aemUri: String) -> ArticleAemCacheObject? {
        
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
    
    func storeAemDataObjects(aemDataObjects: [ArticleAemData], didStartWebArchiveClosure: @escaping ((_ webArchiveOperationQueue: OperationQueue) -> Void), completion: @escaping ((_ result: ArticleAemCacheResult) -> Void)) {
                    
        realmDatabase.background { realm in
            
            typealias AemUri = String
            
            var aemDataDictionary: [AemUri: ArticleAemData] = Dictionary()
            var webArchiveUrls: [WebArchiveUrl] = Array()
            
            for aemData in aemDataObjects {
                
                guard let webUrl = URL(string: aemData.webUrl) else {
                    continue
                }
                
                let dataIsNotCached: Bool
                let uuidChanged: Bool
                
                if let aemCacheObject = self.getAemCacheObject(realm: realm, aemUri: aemData.aemUri),
                   let cachedUUID = aemCacheObject.aemData.articleJcrContent?.uuid,
                   let uuid = aemData.articleJcrContent?.uuid,
                   !cachedUUID.isEmpty,
                   !uuid.isEmpty {
                    
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
            
            let webArchiveOperationQueue = self.webArchiveQueue.archive(webArchiveUrls: webArchiveUrls) { [weak self] (result: WebArchiveQueueResult) in
                
                guard let weakSelf = self else {
                    completion(ArticleAemCacheResult(numberOfArchivedObjects: 0, cacheErrorData: []))
                    return
                }
                
                guard result.successfulArchives.count > 0 else {
                    completion(ArticleAemCacheResult(numberOfArchivedObjects: 0, cacheErrorData: []))
                    return
                }
                
                var aemCacheArchivedObjects: [ArticleAemCacheArchivedObject] = Array()
                
                for webArchiveResult in result.successfulArchives {
                    
                    if let aemData = aemDataDictionary[webArchiveResult.webArchiveUrl.uuid] {
                        
                        let archivedObject = ArticleAemCacheArchivedObject(
                            aemData: aemData,
                            webArchivePlistData: webArchiveResult.webArchivePlistData
                        )
                        
                        aemCacheArchivedObjects.append(archivedObject)
                    }
                }
                
                weakSelf.realmDatabase.background { realm in
                    
                    let articleAemCacheResult = weakSelf.storeAemCacheArchivedObjects(realm: realm, aemCacheArchivedObjects: aemCacheArchivedObjects)
                    
                    completion(articleAemCacheResult)
                }
            }
            
            didStartWebArchiveClosure(webArchiveOperationQueue)
        }
    }
    
    private func storeAemCacheArchivedObjects(realm: Realm, aemCacheArchivedObjects: [ArticleAemCacheArchivedObject]) -> ArticleAemCacheResult {
                
        var cacheErrorData: [ArticleAemCacheErrorData] = Array()
        
        for archivedObject in aemCacheArchivedObjects {
            
            let errorData = storeAemCacheArchivedObject(realm: realm, archivedObject: archivedObject)
            cacheErrorData.append(errorData)
        }
        
        let result = ArticleAemCacheResult(
            numberOfArchivedObjects: aemCacheArchivedObjects.count,
            cacheErrorData: cacheErrorData
        )
        
        return result
    }
    
    private func storeAemCacheArchivedObject(realm: Realm, archivedObject: ArticleAemCacheArchivedObject) -> ArticleAemCacheErrorData {
        
        let aemData: ArticleAemData = archivedObject.aemData
        let aemUri: String = aemData.aemUri
        var cacheErrors: [ArticleAemCacheError] = Array()
        
        if let existingRealmAemData = realm.object(ofType: RealmArticleAemData.self, forPrimaryKey: aemData.aemUri) {
                        
            if let error = removeWebArchivePlistData(webArchiveFilename: existingRealmAemData.webArchiveFilename) {
                cacheErrors.append(.failedToRemoveWebArchivePlistData(error: error))
            }
            
            do {
                try realm.write {
                    existingRealmAemData.mapFrom(model: archivedObject.aemData, ignorePrimaryKey: true)
                }
            }
            catch let error {
                cacheErrors.append(.failedToUpdateExistingRealmArticleAemData(error: error))
            }
            
            if let plistDataCacheError = storeWebArchivePlistData(
                webArchiveFilename: existingRealmAemData.webArchiveFilename,
                webArchivePlistData: archivedObject.webArchivePlistData
            ) {
                cacheErrors.append(plistDataCacheError)
            }
        }
        else {
            
            let webArchiveFilename: String = UUID().uuidString
            
            let realmAemData: RealmArticleAemData = RealmArticleAemData()
            realmAemData.mapFrom(model: aemData, ignorePrimaryKey: false)
            realmAemData.webArchiveFilename = webArchiveFilename
            
            do {
                try realm.write {
                    realm.add(realmAemData)
                }
            }
            catch let error {
                cacheErrors.append(.failedToAddNewRealmArticleAemData(error: error))
            }
            
            if let plistDataCacheError = storeWebArchivePlistData(
                webArchiveFilename: webArchiveFilename,
                webArchivePlistData: archivedObject.webArchivePlistData
            ) {
                cacheErrors.append(plistDataCacheError)
            }
        }
        
        return ArticleAemCacheErrorData(aemUri: aemUri, cacheErrors: cacheErrors)
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
