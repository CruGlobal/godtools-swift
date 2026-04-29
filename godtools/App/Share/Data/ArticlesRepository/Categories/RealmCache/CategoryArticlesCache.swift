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
import GodToolsShared
import Combine

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
    
    private func getCategoryIdAndLanguageCodeNSPredicate(categoryId: String, languageCode: String) -> NSPredicate {
        
        return NSPredicate(format: "\(#keyPath(RealmCategoryArticle.categoryId)) == %@ AND \(#keyPath(RealmCategoryArticle.languageCode)) == %@", categoryId, languageCode)
    }
}

extension CategoryArticlesCache {
    
    func getCategoryArticlesPublisher(categoryId: String, languageCode: String) -> AnyPublisher<[CategoryArticleModel], Never> {
        
        guard let realmDatabase = realmDatabase else {
            return Just([])
                .eraseToAnyPublisher()
        }
        
        return Future() { promise in
            
            realmDatabase.write.serialAsync { result in
                
                switch result {
                    
                case .success( _):
                    
                    do {
                        
                        let categoryArticles: [CategoryArticleModel] = try self.getCategoryArticles(
                            categoryId: categoryId,
                            languageCode: languageCode
                        )
                        
                        promise(.success(categoryArticles))
                    }
                    catch _ {
                        promise(.success([]))
                    }
                    
                case .failure( _):
                    promise(.success([]))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getCategoryArticles(categoryId: String, languageCode: String) throws -> [CategoryArticleModel] {
        
        if let realmDatabase = realmDatabase {
            
            let realm: Realm = try realmDatabase.openRealm()
            
            let query = RealmDatabaseQuery.filter(
                filter: getCategoryIdAndLanguageCodeNSPredicate(
                    categoryId: categoryId,
                    languageCode: languageCode
                )
            )
            
            let objects: [RealmCategoryArticle] = realmDatabase.read.objects(realm: realm, query: query)
            
            return objects.map { $0.toModel() }
        }
        
        return Array()
    }
    
    func storeAemDataObjectsForCategoriesPublisher(categories: [ArticleCategory], languageCode: String, aemDataObjects: [ArticleAemData]) -> AnyPublisher<[Error], Never> {
        
        return Future() { promise in

            self.storeAemDataObjectsForCategories(categories: categories, languageCode: languageCode, aemDataObjects: aemDataObjects) { (errors: [Error]) in
                
                promise(.success(errors))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func storeAemDataObjectsForCategories(categories: [ArticleCategory], languageCode: String, aemDataObjects: [ArticleAemData], completion: @escaping ((_ errors: [Error]) -> Void)) {
        
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
