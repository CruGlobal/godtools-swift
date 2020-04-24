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
                    
                let articleAdded: Bool = articleUrlsByTag.contains(cachedArticleAemImportData.url)
                
                if !articleAdded, let cachedTags = cachedArticleAemImportData.articleJcrContent?.tags, cachedTags.contains(tagId) {
                    
                    articlesByTag.append(cachedArticleAemImportData)
                    articleUrlsByTag.append(cachedArticleAemImportData.url)
                }
            }
        }
        
        return articlesByTag
    }
    
    func cache(articleAemImportData: ArticleAemImportData) -> Error? {
        
        print("\n Cache ArticleAemImportData")
        print("  url: \(String(describing: articleAemImportData.url))")
        print("  title: \(String(describing: articleAemImportData.articleJcrContent?.title))")
        print("  tags: \(String(describing: articleAemImportData.articleJcrContent?.tags))")
        
        let realmArticleAemImportData = RealmArticleAemImportData()
        realmArticleAemImportData.url = articleAemImportData.url
        
        let realmJcrContent = RealmArticleJcrContent()
        let inMemoryJcrContent: ArticleJcrContent? = articleAemImportData.articleJcrContent
        realmJcrContent.canonical = inMemoryJcrContent?.canonical
        realmJcrContent.tags.append(objectsIn: inMemoryJcrContent?.tags ?? [])
        realmJcrContent.title = inMemoryJcrContent?.title
        realmJcrContent.uuid = inMemoryJcrContent?.uuid
        
        realmArticleAemImportData.articleJcrContent = realmJcrContent
                
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
