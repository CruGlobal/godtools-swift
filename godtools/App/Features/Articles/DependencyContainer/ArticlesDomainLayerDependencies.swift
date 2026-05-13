//
//  ArticlesDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class ArticlesDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let coreDomainLayer: AppDomainLayerDependencies
    private let dataLayer: ArticlesDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies, dataLayer: ArticlesDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.coreDomainLayer = coreDomainLayer
        self.dataLayer = dataLayer
    }
    
    func getArticleCategoriesUseCase() -> GetArticleCategoriesUseCase {
        
        return GetArticleCategoriesUseCase(
            manifestResourcesCache: coreDataLayer.getMobileContentRendererManifestResourcesCache(),

        )
    }
    
    func getPullToRefreshArticlesUseCase() -> PullToRefreshArticlesUseCase {
        
        return PullToRefreshArticlesUseCase(
            articleManifestAemRepository: coreDataLayer.getArticleManifestAemRepository()
        )
    }
}
