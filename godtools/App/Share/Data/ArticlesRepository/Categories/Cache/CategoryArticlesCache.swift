//
//  CategoryArticlesCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

final class CategoryArticlesCache {
    
    let persistence: any Persistence<CategoryArticleModel, CategoryArticleModel>
    
    init(persistence: any Persistence<CategoryArticleModel, CategoryArticleModel>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<CategoryArticleModel, CategoryArticleModel, SwiftCategoryArticle>? {
        return persistence as? SwiftRepositorySyncPersistence<CategoryArticleModel, CategoryArticleModel, SwiftCategoryArticle>
    }
    
    private var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<CategoryArticleModel, CategoryArticleModel, RealmCategoryArticle>? {
        return persistence as? RealmRepositorySyncPersistence<CategoryArticleModel, CategoryArticleModel, RealmCategoryArticle>
    }
}

// MARK: - Predicates

extension CategoryArticlesCache {
    
    @available(iOS 17.4, *)
    private func getCategoryIdAndLanguageCodePredicate(categoryId: String, languageCode: String) -> Predicate<SwiftCategoryArticle> {
     
        let filter = #Predicate<SwiftCategoryArticle> { object in
            object.categoryId == categoryId && object.languageCode == languageCode
        }
        
        return filter
    }
    
    private func getCategoryIdAndLanguageCodeNSPredicate(categoryId: String, languageCode: String) -> NSPredicate {
        
        return NSPredicate(format: "\(#keyPath(RealmCategoryArticle.categoryId)) == %@ AND \(#keyPath(RealmCategoryArticle.languageCode)) == %@", categoryId, languageCode)
    }
}

extension CategoryArticlesCache {
    
    func getCategoryArticles(categoryId: String, languageCode: String) async throws -> [CategoryArticleModel] {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let query = SwiftDatabaseQuery.filter(
                filter: getCategoryIdAndLanguageCodePredicate(categoryId: categoryId, languageCode: languageCode)
            )
            
            return try await swiftPersistence.getDataModelsAsync(getOption: .allObjects, query: query)
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let query = RealmDatabaseQuery.filter(
                filter: getCategoryIdAndLanguageCodeNSPredicate(categoryId: categoryId, languageCode: languageCode)
            )
            
            return try await realmPersistence.getDataModelsAsync(getOption: .allObjects, query: query)
        }
        
        return Array()
    }
    
    func storeAemDataObjectsForCategories(categories: [ArticleCategory], languageCode: String, aemDataObjects: [ArticleAemData]) async -> [Error] {
        
        return await withCheckedContinuation { continuation in
            
            storeAemDataObjectsForCategoriesWithCompletion(categories: categories, languageCode: languageCode, aemDataObjects: aemDataObjects) { (errors: [Error]) in
                
                continuation.resume(returning: errors)
            }
        }
    }
    
    private func storeAemDataObjectsForCategoriesWithCompletion(categories: [ArticleCategory], languageCode: String, aemDataObjects: [ArticleAemData], completion: @escaping ((_ errors: [Error]) -> Void)) {
        
        guard let realmDatabase = realmDatabase else {
            completion([])
            return
        }
        
        realmDatabase.write.serialAsync { result in
            
            switch result {
            case .success(let realm):
                
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
                        realmCategoryArticle.id = categoryArticleUUID.uuidString
                        
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
                
            case .failure(let error):
                completion([error])
            }
        }
    }
}
