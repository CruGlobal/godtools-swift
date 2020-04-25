//
//  RealmArticleAemImportDataCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmArticleAemImportDataCache: ArticleAemImportDataCacheType {
    
    private let realm: Realm
    
    required init(realm: Realm) {
        
        self.realm = realm
    }
    
    var dataExistsInCache: Bool {
        return realm.objects(RealmArticleAemImportData.self).count > 0
    }
    
    func getArticlesWithTags(aemTags: [String]) -> [RealmArticleAemImportData] {
        
        var articlesByTag: [RealmArticleAemImportData] = Array()
        var articleUrlsByTag: [String] = Array()
        
        let cachedArticleAemImportDataArray: [RealmArticleAemImportData] = Array(realm.objects(RealmArticleAemImportData.self))
        
        for tagId in aemTags {
            
            for cachedArticleAemImportData in cachedArticleAemImportDataArray {
                    
                let articleAdded: Bool = articleUrlsByTag.contains(cachedArticleAemImportData.webUrl)
                
                if !articleAdded, let cachedTags = cachedArticleAemImportData.articleJcrContent?.tags, cachedTags.contains(tagId) {
                    
                    articlesByTag.append(cachedArticleAemImportData)
                    articleUrlsByTag.append(cachedArticleAemImportData.webUrl)
                }
            }
        }
        
        return articlesByTag
    }
    
    func cache(articleAemImportData: ArticleAemImportData) -> Error? {
                
        let inMemoryJcrContent: ArticleJcrContent? = articleAemImportData.articleJcrContent
        
        let realmJcrContent = RealmArticleJcrContent(
            canonical: inMemoryJcrContent?.canonical,
            title: inMemoryJcrContent?.title,
            uuid: inMemoryJcrContent?.uuid,
            tags: inMemoryJcrContent?.tags ?? []
        )
        
        let realmArticleAemImportData = RealmArticleAemImportData(
            articleJcrContent: realmJcrContent,
            id: articleAemImportData.id,
            webUrl: articleAemImportData.webUrl
        )
                        
        do {
            try realm.write {
                realm.add(realmArticleAemImportData)
            }
            return nil
        }
        catch let error {
            print("\n \(String(describing: RealmArticleAemImportDataCache.self)) Failed to cache articleAemImportData with error: \(error)")
            return error
        }
    }
    
    func deleteAllData() -> Error? {
        
        let results: Results<RealmArticleAemImportData> = realm.objects(RealmArticleAemImportData.self)
        if !results.isEmpty {
            do {
                try realm.write {
                    realm.delete(results)
                }
                return nil
            }
            catch let error {
                return error
            }
        }
        
        return nil
    }
}
