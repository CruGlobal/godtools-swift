//
//  ArticlesDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class ArticlesDiContainer {
        
    private let dataLayer: ArticlesDataLayerDependencies
    
    let domainLayer: ArticlesDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        self.dataLayer = ArticlesDataLayerDependencies(coreDataLayer: coreDataLayer)
        self.domainLayer = ArticlesDomainLayerDependencies(coreDataLayer: coreDataLayer, coreDomainLayer: coreDomainLayer, dataLayer: dataLayer)
    }
}
