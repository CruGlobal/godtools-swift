//
//  GetArticlesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 6/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetArticlesUseCase {
    
    private let articlesRepsoitory: ArticleManifestAemRepository
    
    init(articlesRepsoitory: ArticleManifestAemRepository) {
        
        self.articlesRepsoitory = articlesRepsoitory
    }
    
    func execute(
        category: ArticleCategoryDomainModel,
        languageCode: BCP47LanguageIdentifier
    ) async throws -> [ArticleListItemDomainModel] {
        
        let categoryArticles: [CategoryArticleDataModel] = try await articlesRepsoitory.getCategoryArticles(
            categoryId: category.id,
            languageCode: languageCode
        )
        
        var uniqueAemUris: Set<String> = Set()
        
        for article in categoryArticles {
            for uri in article.aemUris {
                uniqueAemUris.insert(uri)
            }
        }
        
        let aemUris: [String] = uniqueAemUris.sorted()
        
        let aemCacheObjects: [ArticleAemCacheObject] = try articlesRepsoitory.getAemCacheObjects(
            aemUris: aemUris
        )
        
        let sortedAemCacheObjects: [ArticleAemCacheObject] = aemCacheObjects.sorted(by: {
            let thisTitle: String? = $0.aemData.articleJcrContent?.title
            let thatTitle: String? = $1.aemData.articleJcrContent?.title
            
            if let thisTitle = thisTitle, let thatTitle = thatTitle {
                return thisTitle < thatTitle
            }
            
            return false
        })
        
        let articles: [ArticleListItemDomainModel] = sortedAemCacheObjects.map {
            ArticleListItemDomainModel(
                id: $0.aemUri,
                title: $0.aemData.articleJcrContent?.title ?? ""
            )
        }
        
        return articles
    }
}
