//
//  ArticlesDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

@MainActor
final class ArticlesDiContainer {
        
    private let dataLayer: ArticlesDataLayerDependencies
    
    let domainLayer: ArticlesDomainLayerDependencies
    
    init(dataLayer: ArticlesDataLayerDependencies, domainLayer: ArticlesDomainLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
