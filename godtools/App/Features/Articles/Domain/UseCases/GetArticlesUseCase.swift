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
    private let localizationServices: LocalizationServicesInterface
    private let getDownloadArticlesErrorMessage: GetDownloadArticlesErrorMessage
    
    init(
        articlesRepsoitory: ArticleManifestAemRepository,
        localizationServices: LocalizationServicesInterface,
        getDownloadArticlesErrorMessage: GetDownloadArticlesErrorMessage
    ) {
        
        self.articlesRepsoitory = articlesRepsoitory
        self.localizationServices = localizationServices
        self.getDownloadArticlesErrorMessage = getDownloadArticlesErrorMessage
    }
    
    func execute(
        appLanguage: AppLanguageDomainModel,
        category: ArticleCategoryDomainModel,
        languageCode: BCP47LanguageIdentifier
    ) async throws -> ArticlesDomainModel {
        
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
        
        guard !articles.isEmpty else {
            
            let title: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.downloadError.key)
            let downloadActionTitle: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.articlesRetryDownloadButtonTitle.key)
            
            let aemDataObjects: [ArticleAemData] = try await articlesRepsoitory.getArticleAemDataObjects()
            let error: Error? = aemDataObjects.compactMap { $0.error }.first
            let message: String
            
            if let error = error {
                message = getDownloadArticlesErrorMessage.getErrorMessage(appLanguage: appLanguage, error: error)
            }
            else {
                message = localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: appLanguage,
                    key: LocalizableStringKeys.downloadError.key
                )
            }
            
            return ArticlesDomainModel(
                articleListItems: [],
                error: ArticlesErrorDomainModel(
                    title: title,
                    message: message,
                    downloadActionTitle: downloadActionTitle
                )
            )
        }
        
        return ArticlesDomainModel(
            articleListItems: articles,
            error: nil
        )
    }
}
