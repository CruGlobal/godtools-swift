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
    
    func getArticleAemImportDataObjects(godToolsResource: GodToolsResource) -> [RealmArticleAemImportData] {
        
        let filter: String = "resourceId = '\(godToolsResource.resourceId)' AND languageCode = '\(godToolsResource.languageCode)'"
        let cachedArticleAemImportDataObjects: [RealmArticleAemImportData] = Array(realm.objects(RealmArticleAemImportData.self).filter(filter))
        
        return cachedArticleAemImportDataObjects
    }
    
    func getArticlesWithTags(godToolsResource: GodToolsResource, aemTags: [String]) -> [RealmArticleAemImportData] {
        
        var articlesByTag: [RealmArticleAemImportData] = Array()
        var articleUrlsByTag: [String] = Array()
        
        let cachedArticleAemImportDataObjects: [RealmArticleAemImportData] = getArticleAemImportDataObjects(godToolsResource: godToolsResource)
                
        for tagId in aemTags {
            
            for cachedArticleAemImportData in cachedArticleAemImportDataObjects {
                    
                let articleAdded: Bool = articleUrlsByTag.contains(cachedArticleAemImportData.webUrl)
                
                if !articleAdded, let cachedTags = cachedArticleAemImportData.articleJcrContent?.tags, cachedTags.contains(tagId) {
                    
                    articlesByTag.append(cachedArticleAemImportData)
                    articleUrlsByTag.append(cachedArticleAemImportData.webUrl)
                }
            }
        }
        
        return articlesByTag
    }
    
    func cache(articleAemImportDataObjects: [ArticleAemImportData], complete: @escaping ((_ error: Error?) -> Void)) {
        
        var realmArticleAemImportDataArray: [RealmArticleAemImportData] = Array()
        
        for articleAemImportData in articleAemImportDataObjects {
            
            let inMemoryJcrContent: ArticleJcrContent? = articleAemImportData.articleJcrContent
            
            let realmJcrContent = RealmArticleJcrContent(
                canonical: inMemoryJcrContent?.canonical,
                title: inMemoryJcrContent?.title,
                uuid: inMemoryJcrContent?.uuid,
                tags: inMemoryJcrContent?.tags ?? []
            )
            
            let realmArticleAemImportData = RealmArticleAemImportData(
                articleJcrContent: realmJcrContent,
                languageCode: articleAemImportData.languageCode,
                resourceId: articleAemImportData.resourceId,
                webUrl: articleAemImportData.webUrl,
                webArchiveFilename: articleAemImportData.webArchiveFilename
            )
            
            realmArticleAemImportDataArray.append(realmArticleAemImportData)
        }
        
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
    
    func deleteAemImportDataObjects(godToolsResource: GodToolsResource) -> Error? {
        
        let cachedArticleAemImportDataObjects: [RealmArticleAemImportData] = getArticleAemImportDataObjects(godToolsResource: godToolsResource)
        
        do {
            try realm.write {
                realm.delete(cachedArticleAemImportDataObjects)
            }
            return nil
        }
        catch let error {
            return error
        }
    }
    
    func deleteAllAemImportDataObjects() -> Error? {
        
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
