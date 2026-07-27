//
//  RealmCategoryArticlesCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

final class RealmCategoryArticlesCache: CategoryArticlesCacheInterface {
    
    private let persistence: RealmRepositorySyncPersistence<CategoryArticleDataModel, CategoryArticleDataModel, RealmCategoryArticle>
    private let realmDataWrite: RealmDataWrite
    
    init(
        persistence: RealmRepositorySyncPersistence<CategoryArticleDataModel, CategoryArticleDataModel, RealmCategoryArticle>,
        realmDataWrite: RealmDataWrite
    ) {
                
        self.persistence = persistence
        self.realmDataWrite = realmDataWrite
    }
    
    private func getCategoryIdAndLanguageCodeNSPredicate(categoryId: String, languageCode: String) -> NSPredicate {
        
        return NSPredicate(format: "\(#keyPath(RealmCategoryArticle.categoryId)) == %@ AND \(#keyPath(RealmCategoryArticle.languageCode)) == %@", categoryId, languageCode)
    }
    
    func getCategoryArticles(categoryId: String, languageCode: String) async throws -> [CategoryArticleDataModel] {
        
        let query = RealmDatabaseQuery.filter(
            filter: getCategoryIdAndLanguageCodeNSPredicate(categoryId: categoryId, languageCode: languageCode)
        )
        
        return try await persistence
            .newActorRead()
            .getDataModels(query: query)
    }
    
    func storeAemDataObjectsForCategories(
        categories: [ManifestCategory],
        languageCode: String,
        aemDataObjects: [ArticleAemData]
    ) async -> [Error] {
        
        return await withCheckedContinuation { continuation in
            
            storeAemDataObjectsForCategoriesWithCompletion(categories: categories, languageCode: languageCode, aemDataObjects: aemDataObjects) { (errors: [Error]) in
                
                continuation.resume(returning: errors)
            }
        }
    }
    
    private func storeAemDataObjectsForCategoriesWithCompletion(
        categories: [ManifestCategory],
        languageCode: String,
        aemDataObjects: [ArticleAemData],
        completion: @escaping ((_ errors: [Error]) -> Void)
    ) {
        
        realmDataWrite.serialAsync { result in
            
            switch result {
            case .success(let realm):
                
                typealias AemTag = String
                
                var realmCategoryArticles: [AemTag: RealmCategoryArticle] = Dictionary()
                var errors: [Error] = Array()
                
                var categoryArticlesToCache: [RealmCategoryArticle] = Array()
                
                for category in categories {
                                   
                    for aemTag in category.aemTags {
                        
                        let categoryArticleUUID = CategoryArticleDataModel.UUID(categoryId: category.id, languageCode: languageCode, aemTag: aemTag)
                        
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
