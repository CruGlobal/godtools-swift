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
    
    func getData(tagId: String) -> [RealmArticleAemImportData] {
                
        let cachedArticleAemImportDataArray: [RealmArticleAemImportData] = Array(realm.objects(RealmArticleAemImportData.self))
        
        var articleAemImportDataByTag: [RealmArticleAemImportData] = Array()
        
        for cachedArticleAemImportData in cachedArticleAemImportDataArray {
            
            if let tags = cachedArticleAemImportData.articleJcrContent?.tags, tags.contains(tagId) {
                
                articleAemImportDataByTag.append(cachedArticleAemImportData)
            }
        }
                
        return articleAemImportDataByTag
    }
    
    func cache(articleAemImportData: ArticleAemImportData) -> Error? {
        
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
