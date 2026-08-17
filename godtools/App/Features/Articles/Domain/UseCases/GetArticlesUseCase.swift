//
//  GetArticlesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 6/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetArticlesUseCase: Sendable {
    
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
        
        let aemCacheObjects: [ArticleAemCacheObject] = try await articlesRepsoitory.getAemCacheObjects(
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
        
        if articles.isEmpty, let error = try await getFirstArticleError() {
            
            let titleKey: String = LocalizableStringKeys.downloadError.key
            let downloadActionTitleKey: String = LocalizableStringKeys.articlesRetryDownloadButtonTitle.key

            let strings: [String: String] = localizationServices.stringsForKeys(
                keys: [
                    titleKey,
                    downloadActionTitleKey
                ],
                fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
                shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
            )

            let title: String = strings[titleKey] ?? ""
            let downloadActionTitle: String = strings[downloadActionTitleKey] ?? ""
            
            let message: String = getDownloadArticlesErrorMessage.getErrorMessage(
                appLanguage: appLanguage,
                error: error
            )
            
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
    
    private func getFirstArticleError() async throws -> Error? {
        
        let aemDataObjects: [ArticleAemData] = try await articlesRepsoitory.getArticleAemDataObjects()
        let error: Error? = aemDataObjects.compactMap { $0.error }.first
        
        return error
    }
}
