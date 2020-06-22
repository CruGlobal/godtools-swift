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
    
    func getArticleAemImportDataObjects(godToolsResource: GodToolsResource, complete: @escaping ((_ articleAemImportData: [RealmArticleAemImportData]) -> Void)) {
        
        realmDatabase.background { [weak self] (realm: Realm) in
            
            let realmArticleAemImportData: [RealmArticleAemImportData] = self?.getArticleAemImportDataObjects(realm: realm, godToolsResource: godToolsResource) ?? []
            
            complete(realmArticleAemImportData)
        }
    }
    
    func getArticleAemImportDataObjects(realm: Realm, godToolsResource: GodToolsResource) -> [RealmArticleAemImportData] {
        
        let filter: String = "resourceId = '\(godToolsResource.resourceId)' AND languageCode = '\(godToolsResource.languageCode)'"
        let realmArticleAemImportData: [RealmArticleAemImportData] = Array(realm.objects(RealmArticleAemImportData.self).filter(filter))
        
        return realmArticleAemImportData
    }
    
    func getArticlesWithTags(godToolsResource: GodToolsResource, aemTags: [String], complete: @escaping ((_ articleAemImportData: [RealmArticleAemImportData]) -> Void)) {
        
        realmDatabase.background { [weak self] (realm: Realm) in
            
            var articlesByTag: [RealmArticleAemImportData] = Array()
            var articleUrlsByTag: [String] = Array()
            
            let cachedArticleAemImportDataObjects: [RealmArticleAemImportData] = self?.getArticleAemImportDataObjects(realm: realm, godToolsResource: godToolsResource) ?? []
            
            for tagId in aemTags {
                
                for cachedArticleAemImportData in cachedArticleAemImportDataObjects {
                        
                    let articleAdded: Bool = articleUrlsByTag.contains(cachedArticleAemImportData.webUrl)
                    
                    if !articleAdded, let cachedTags = cachedArticleAemImportData.articleJcrContent?.tags, cachedTags.contains(tagId) {
                        
                        articlesByTag.append(cachedArticleAemImportData)
                        articleUrlsByTag.append(cachedArticleAemImportData.webUrl)
                    }
                }
            }
            
            complete(articlesByTag)
        }
    }
    
    func cache(articleAemImportDataObjects: [ArticleAemImportData], complete: @escaping ((_ error: Error?) -> Void)) {
        
        realmDatabase.background { (realm: Realm) in
            
            let realmArticleAemImportDataArray: [RealmArticleAemImportData] = articleAemImportDataObjects.map({
                let realmArticleAemImportData = RealmArticleAemImportData()
                realmArticleAemImportData.mapFrom(model: $0)
                return realmArticleAemImportData
            })
            
            do {
                try realm.write {
                    realm.add(realmArticleAemImportDataArray)
                    complete(nil)
                }
            }
            catch let error {
                complete(error)
            }
        }
    }
    
    func deleteAemImportDataObjects(godToolsResource: GodToolsResource, complete: @escaping ((_ error: Error?) -> Void)) {
        
        realmDatabase.background { [weak self] (realm: Realm) in
            
            let cachedArticleAemImportDataObjects: [RealmArticleAemImportData] = self?.getArticleAemImportDataObjects(realm: realm, godToolsResource: godToolsResource) ?? []
            
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
            
            if !results.isEmpty {
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
}
