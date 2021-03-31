//
//  RealmCategoryArticlesCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmCategoryArticlesCache {
    
    private let realmDatabase: RealmDatabase
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getCategoryArticles(category: ArticleCategory, languageCode: String) -> [RealmCategoryArticle] {
        
        let realm: Realm = realmDatabase.mainThreadRealm
        let allRealmArticles = realm.objects(RealmCategoryArticle.self)
        
        let predicate = NSPredicate(format: "categoryId == %@ AND languageCode == %@", category.id, languageCode)
        
        return Array(allRealmArticles.filter(predicate))
    }
    
    func getCategoryArticleOnMainThread(uuid: CategoryArticleUUID) -> RealmCategoryArticle? {
        
        return getCategoryArticle(realm: realmDatabase.mainThreadRealm, uuid: uuid)
    }
    
    func getCategoryArticle(realm: Realm, uuid: CategoryArticleUUID) -> RealmCategoryArticle? {
        
        return realm.object(ofType: RealmCategoryArticle.self, forPrimaryKey: uuid.uuidString)
    }
    
    func storeArticleAemDataForManifestCategories(manifest: ArticleManifestType, languageCode: String, downloadedManifestAemDataImports: [ArticleAemImportData], completion: @escaping ((_ errors: [Error]) -> Void)) {
        
        realmDatabase.background { [weak self] (realm: Realm) in
            
            typealias AemTag = String
            
            let categories: [ArticleCategory] = manifest.categories
            var realmCategoryArticles: [AemTag: RealmCategoryArticle] = Dictionary()
            var errors: [Error] = Array()
            
            for category in categories {
                
                let categoryId: String = category.id
               
                for aemTag in category.aemTags {
                    
                    let categoryUUID = CategoryArticleUUID(
                        categoryId: categoryId,
                        languageCode: languageCode,
                        aemTag: aemTag
                    )
                    
                    let categoryArticle: RealmCategoryArticle
                    
                    if let cachedCategoryArticle = self?.getCategoryArticle(realm: realm, uuid: categoryUUID) {
                        
                        categoryArticle = cachedCategoryArticle
                    }
                    else {
                        
                        categoryArticle = RealmCategoryArticle()
                        
                        categoryArticle.aemTag = aemTag
                        categoryArticle.categoryId = categoryId
                        categoryArticle.languageCode = languageCode
                        categoryArticle.uuid = categoryUUID.uuidString
                        
                        do {
                            try realm.write {
                                realm.add(categoryArticle)
                            }
                        }
                        catch let error {
                            errors.append(error)
                        }
                    }
                    
                    realmCategoryArticles[aemTag] = categoryArticle
                }//end category aemTags
            }//end categories
            
            for aemData in downloadedManifestAemDataImports {
                
                let jcrAemTags: [String] = aemData.articleJcrContent?.tags ?? []
                
                for jcrAemTag in jcrAemTags {
                    
                    for category in categories {
                        
                        if category.aemTags.contains(jcrAemTag) {
                            
                            if let realmCategoryArticle = realmCategoryArticles[jcrAemTag] {
                                
                                do {
                                    try realm.write {
                                        if !realmCategoryArticle.aemUris.contains(aemData.aemUri) {
                                            realmCategoryArticle.aemUris.append(aemData.aemUri)
                                        }
                                    }
                                }
                                catch let error {
                                    errors.append(error)
                                }
                            }
                        }
                    }
                }
            }
            
            completion(errors)
            
        }//end realm background
    }
}
