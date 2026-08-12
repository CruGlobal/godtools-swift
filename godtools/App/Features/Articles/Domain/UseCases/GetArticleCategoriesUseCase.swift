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

final class GetArticleCategoriesUseCase: Sendable {
    
    private let resourcesFileCache: ResourcesFileCache
    
    init(resourcesFileCache: ResourcesFileCache) {
        
        self.resourcesFileCache = resourcesFileCache
    }
    
    func execute(manifest: Manifest) async -> [ArticleCategoryDomainModel] {
        
        var articleCategories: [ArticleCategoryDomainModel] = Array()
        
        for category in manifest.categories {
            
            guard let id = category.id, let label = category.label?.text else {
                continue
            }
            
            let image: SwiftUI.Image? = await getImage(category: category)
            
            let articleCategory = ArticleCategoryDomainModel(
                id: id,
                title: label,
                image: image
            )
            
            articleCategories.append(articleCategory)
        }
        
        return articleCategories
    }
    
    private func getImage(category: GodToolsShared.Category) async -> SwiftUI.Image? {
        
        guard let bannerResource = category.banner, let fileLocation = bannerResource.toSHA256FileLocation() else {
            return nil
        }
        
        return await resourcesFileCache.cache.getImageNonThrowing(location: fileLocation)
    }
}
