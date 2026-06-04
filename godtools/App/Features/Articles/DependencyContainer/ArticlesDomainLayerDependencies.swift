//
//  ArticlesDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class ArticlesDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: ArticlesDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: ArticlesDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getArticleCategoriesUseCase() -> GetArticleCategoriesUseCase {
        
        return GetArticleCategoriesUseCase(
            manifestResourcesCache: core.dataLayer.getMobileContentRendererManifestResourcesCache(),

        )
    }
    
    func getArticlesUseCase() -> GetArticlesUseCase {
        return GetArticlesUseCase(
            articlesRepsoitory: core.dataLayer.getArticleManifestAemRepository()
        )
    }
    
    func getArticleUseCase() -> GetArticleUseCase {
        return GetArticleUseCase(
            articleRepository: core.dataLayer.getArticleAemRepository()
        )
    }
    
    func getPullToRefreshArticlesUseCase() -> PullToRefreshArticlesUseCase {
        
        return PullToRefreshArticlesUseCase(
            articleManifestAemRepository: core.dataLayer.getArticleManifestAemRepository()
        )
    }
    
    func getShareArticleUseCase() -> ShareArticleUseCase {
        return ShareArticleUseCase(
            articleRepository: core.dataLayer.getArticleAemRepository()
        )
    }
}
