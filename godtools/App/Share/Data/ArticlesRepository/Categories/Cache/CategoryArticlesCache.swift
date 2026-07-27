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

        typealias AemTag = String

        var errors: [Error] = Array()

        let swiftDataRead = SwiftDataRead()

        var categoryArticlesByAemTag: [AemTag: SwiftCategoryArticle] = Dictionary()
        var categoryArticlesToStore: [SwiftCategoryArticle] = Array()

        for category in categories {

            for aemTag in category.aemTags {

                let categoryArticleUUID = CategoryArticleDataModel.UUID(categoryId: category.id, languageCode: languageCode, aemTag: aemTag)

                let existingAemUris: [String]

                do {
                    let existingCategoryArticle: SwiftCategoryArticle? = try swiftDataRead.object(context: modelContext, id: categoryArticleUUID.uuidString)
                    existingAemUris = existingCategoryArticle?.aemUris ?? Array()
                }
                catch let error {
                    errors.append(error)
                    existingAemUris = Array()
                }

                let categoryArticle = SwiftCategoryArticle()

                categoryArticle.aemTag = aemTag
                categoryArticle.aemUris = existingAemUris
                categoryArticle.categoryId = category.id
                categoryArticle.languageCode = languageCode
                categoryArticle.uuid = categoryArticleUUID.uuidString
                categoryArticle.id = categoryArticleUUID.uuidString

                categoryArticlesToStore.append(categoryArticle)

                categoryArticlesByAemTag[aemTag] = categoryArticle
            }
        }

        modelContext.insertObjects(objects: categoryArticlesToStore)

        do {
            try modelContext.saveIfHasChanges()
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

                    guard let categoryArticle = categoryArticlesByAemTag[jcrAemTag] else {
                        continue
                    }

                    guard !categoryArticle.aemUris.contains(aemData.aemUri) else {
                        continue
                    }

                    categoryArticle.aemUris.append(aemData.aemUri)
                }
            }
        }

        do {
            try modelContext.saveIfHasChanges()
        }
        catch let error {
            errors.append(error)
        }

        return errors
    }
}
