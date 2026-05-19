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
    
    init(core: AppCoreDiContainer) {
        
        self.dataLayer = ArticlesDataLayerDependencies(coreDataLayer: core.dataLayer)
        self.domainLayer = ArticlesDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
