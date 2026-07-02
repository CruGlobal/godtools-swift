//
//  GetArticleCategoriesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import GodToolsShared
import SwiftUI

final class GetArticleCategoriesUseCase {
    
    private let manifestResourcesCache: MobileContentRendererManifestResourcesCache
    
    init(manifestResourcesCache: MobileContentRendererManifestResourcesCache) {
        
        self.manifestResourcesCache = manifestResourcesCache
    }
    
    func execute(manifest: Manifest) -> [ArticleCategoryDomainModel] {
        
        let categories: [ArticleCategoryDomainModel] = manifest.categories.compactMap {
            
            guard let id = $0.id, let label = $0.label?.text else {
                return nil
            }
            
            return ArticleCategoryDomainModel(
                id: id,
                title: label,
                image: getImage(category: $0)
            )
        }
        
        return categories
    }
    
    private func getImage(category: GodToolsShared.Category) -> SwiftUI.Image? {
        
        guard let bannerResource = category.banner else {
            return nil
        }
        
        return manifestResourcesCache.getImageNonThrowing(resource: bannerResource)
    }
}
