//
//  RealmArticleAemImportDataCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmArticleAemImportDataCache {
    
    private let realmDatabase: RealmDatabase
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getArticleAemImportDataObjects(resourceId: String, languageCode: String, complete: @escaping ((_ articleAemImportData: [RealmArticleAemImportData]) -> Void)) {
        
        realmDatabase.background { [weak self] (realm: Realm) in
            
            let realmArticleAemImportData: [RealmArticleAemImportData] = self?.getArticleAemImportDataObjects(realm: realm, resourceId: resourceId, languageCode: languageCode) ?? []
            
            complete(realmArticleAemImportData)
        }
    }
    
    func getArticleAemImportDataObjects(realm: Realm, resourceId: String, languageCode: String) -> [RealmArticleAemImportData] {
        
        // This method is no longer valid, no longer cacheing articles by resourceId and languageCode. ~Levi
        
        /*let filter: String = "resourceId = '\(resourceId)' AND languageCode = '\(languageCode)'"
        let realmArticleAemImportData: [RealmArticleAemImportData] = Array(realm.objects(RealmArticleAemImportData.self).filter(filter))
        
        return realmArticleAemImportData*/
        
        return []
    }
    
    func getArticlesWithTags(resourceId: String, languageCode: String, aemTags: [String], completeOnMain: @escaping ((_ articleAemImportData: [ArticleAemImportData]) -> Void)) {
        
        realmDatabase.background { [weak self] (realm: Realm) in
            
            var articlesByTag: [RealmArticleAemImportData] = Array()
            var articleUrlsByTag: [String] = Array()
            
            let cachedArticleAemImportDataObjects: [RealmArticleAemImportData] = self?.getArticleAemImportDataObjects(realm: realm, resourceId: resourceId, languageCode: languageCode) ?? []
            
            for tagId in aemTags {
                
                for cachedArticleAemImportData in cachedArticleAemImportDataObjects {
                        
                    let articleAdded: Bool = articleUrlsByTag.contains(cachedArticleAemImportData.webUrl)
                    
                    if !articleAdded, let cachedTags = cachedArticleAemImportData.articleJcrContent?.tags, cachedTags.contains(tagId) {
                        articlesByTag.append(cachedArticleAemImportData)
                        articleUrlsByTag.append(cachedArticleAemImportData.webUrl)
                    }
                }
            }
            
            let articleAemImportData: [ArticleAemImportData] = articlesByTag.map({ArticleAemImportData(realmModel: $0)})
            
            DispatchQueue.main.async {
                completeOnMain(articleAemImportData)
            }
        }
    }
    
    func cache(articleAemImportDataObjects: [ArticleAemImportData], complete: @escaping ((_ error: Error?) -> Void)) {
        
        // TODO: We will need to update this. ArticleAemImportData objects now have a primaryKey so we will have to check for existing objects first and update those instead of adding new objects. ~Levi
        
        realmDatabase.background { (realm: Realm) in
            
            let realmArticleAemImportDataArray: [RealmArticleAemImportData] = articleAemImportDataObjects.map({
                let realmArticleAemImportData = RealmArticleAemImportData()
                realmArticleAemImportData.mapFrom(model: $0)
                return realmArticleAemImportData
            })
            
            /*
            do {
                try realm.write {
                    realm.add(realmArticleAemImportDataArray)
                    complete(nil)
                }
            }
            catch let error {
                complete(error)
            }*/
            
            
            complete(nil)// TODO: Remove this completion. ~Levi
        }
    }
    
    func deleteAemImportDataObjects(resourceId: String, languageCode: String, complete: @escaping ((_ error: Error?) -> Void)) {
        
        realmDatabase.background { [weak self] (realm: Realm) in
            
            let cachedArticleAemImportDataObjects: [RealmArticleAemImportData] = self?.getArticleAemImportDataObjects(realm: realm, resourceId: resourceId, languageCode: languageCode) ?? []
            
            do {
                try realm.write {
                    realm.delete(cachedArticleAemImportDataObjects)
                }
                complete(nil)
            }
            catch let error {
                complete(error)
            }
        }
    }
    
    func deleteAllAemImportDataObjects(complete: @escaping ((_ error: Error?) -> Void)) {
        
        realmDatabase.background { (realm: Realm) in
            
            let results: Results<RealmArticleAemImportData> = realm.objects(RealmArticleAemImportData.self)
            
            guard !results.isEmpty else {
                complete(nil)
                return
            }
            
            do {
                try realm.write {
                    realm.delete(results)
                }
                complete(nil)
            }
            catch let error {
                complete(error)
            }
        }
    }
}
