//
//  RealmCategoryArticlesCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import GodToolsToolParser

class RealmCategoryArticlesCache {
    
    private let realmDatabase: RealmDatabase
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getCategoryArticles(categoryId: String, languageCode: String) -> [CategoryArticleModel] {
        
        return realmDatabase.openRealm().objects(RealmCategoryArticle.self)
            .filter(NSPredicate(format: "categoryId == %@ AND languageCode == %@", categoryId, languageCode))
            .map({CategoryArticleModel(realmModel: $0)})
    }
    
    func storeAemDataObjectsForCategories(categories: [ArticleCategory], languageCode: String, aemDataObjects: [ArticleAemData], completion: @escaping ((_ errors: [Error]) -> Void)) {
        
        realmDatabase.background { (realm: Realm) in
            
            typealias AemTag = String
            
            var realmCategoryArticles: [AemTag: RealmCategoryArticle] = Dictionary()
            var errors: [Error] = Array()
            
            var categoryArticlesToCache: [RealmCategoryArticle] = Array()
            
            for category in categories {
                               
                for aemTag in category.aemTags {
                    
                    let categoryArticleUUID = CategoryArticleUUID(categoryId: category.id, languageCode: languageCode, aemTag: aemTag)
                    
                    let aemUris: List<String>
                    
                    if let existingRealmCategoryArticle = realm.object(ofType: RealmCategoryArticle.self, forPrimaryKey: categoryArticleUUID.uuidString) {
                        aemUris = existingRealmCategoryArticle.aemUris
                    }
                    else {
                        aemUris = List<String>()
                    }
                    
                    let realmCategoryArticle = RealmCategoryArticle()
                    
                    realmCategoryArticle.aemTag = aemTag
                    realmCategoryArticle.aemUris.removeAll()
                    realmCategoryArticle.aemUris.append(objectsIn: aemUris)
                    realmCategoryArticle.categoryId = category.id
                    realmCategoryArticle.languageCode = languageCode
                    realmCategoryArticle.uuid = categoryArticleUUID.uuidString
                    
                    categoryArticlesToCache.append(realmCategoryArticle)
                    
                    realmCategoryArticles[aemTag] = realmCategoryArticle
                }
            }
            
            do {
                try realm.write {
                    realm.add(categoryArticlesToCache, update: .all)
                }
            }
            catch let error {
                errors.append(error)
            }
            
            for aemData in aemDataObjects {
                
                let jcrAemTags: [String] = aemData.articleJcrContent?.tags ?? []
                
                for jcrAemTag in jcrAemTags {
                    
                    for category in categories {
                        
                        guard category.aemTags.contains(jcrAemTag) else {
                            continue
                        }
                        
                        guard let realmCategoryArticle = realmCategoryArticles[jcrAemTag] else {
                            continue
                        }
                        
                        guard !realmCategoryArticle.aemUris.contains(aemData.aemUri) else {
                            continue
                        }
                        
                        do {
                            try realm.write {
                                realmCategoryArticle.aemUris.append(aemData.aemUri)
                            }
                        }
                        catch let error {
                            errors.append(error)
                        }
                    }
                }
            }
            
            completion(errors)
            
        }//end realm background
    }
}
