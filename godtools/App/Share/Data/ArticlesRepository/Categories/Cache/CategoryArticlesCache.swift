//
//  CategoryArticlesCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import SwiftData

@available(iOS 17.4, *)
actor CategoryArticlesCache: CategoryArticlesCacheInterface, ModelActor {
    
    let modelContainer: ModelContainer
    let modelExecutor: ModelExecutor
    
    init(container: ModelContainer) {
                
        self.modelContainer = container
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(container))
    }
    
    private func getCategoryIdAndLanguageCodePredicate(categoryId: String, languageCode: String) -> Predicate<SwiftCategoryArticle> {
     
        let filter = #Predicate<SwiftCategoryArticle> { object in
            object.categoryId == categoryId && object.languageCode == languageCode
        }
        
        return filter
    }
    
    func getCategoryArticles(categoryId: String, languageCode: String) async throws -> [CategoryArticleDataModel] {
        
        let query = SwiftDatabaseQuery.filter(
            filter: getCategoryIdAndLanguageCodePredicate(categoryId: categoryId, languageCode: languageCode)
        )
        
        let objects: [SwiftCategoryArticle] = try SwiftDataRead().objects(context: modelContext, query: query)
        
        return objects.map { $0.toModel() }
    }
    
    func storeAemDataObjectsForCategories(
        categories: [ManifestCategory],
        languageCode: String,
        aemDataObjects: [ArticleAemData]
    ) async -> [Error] {
        
        return Array()
    }
}
