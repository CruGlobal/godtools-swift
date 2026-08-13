//
//  GetArticleCategoriesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftUI

final class GetArticleCategoriesUseCase: Sendable {
    
    private let resourcesFileCache: ResourcesFileCache
    
    init(resourcesFileCache: ResourcesFileCache) {
        
        self.resourcesFileCache = resourcesFileCache
    }
    
    func execute(categories: [SendableCategory]) async -> [ArticleCategoryDomainModel] {
        
        return await getArticleCategories(categories: categories)
    }
    
    private func getArticleCategories(categories: [SendableCategory]) async -> [ArticleCategoryDomainModel] {
        
        await withTaskGroup(of: ArticleCategoryDomainModel?.self) { group in
            
            for category in categories {
                
                group.addTask {
                    
                    guard let id = category.id, let labelText = category.labelText else {
                        return nil
                    }
                    
                    let image = await self.getImage(category: category)
                    
                    return ArticleCategoryDomainModel(
                        id: id,
                        title: labelText,
                        image: image
                    )
                }
            }
            
            var articleCategories: [ArticleCategoryDomainModel] = Array()
            
            for await category in group {
                guard let category = category else {
                    continue
                }
                articleCategories.append(category)
            }
            
            return articleCategories
        }
    }
    
    private func getImage(category: SendableCategory) async -> SwiftUI.Image? {
        
        guard let fileLocation = category.bannerLocation else {
            return nil
        }
        
        return await resourcesFileCache.cache.getImageNonThrowing(location: fileLocation)
    }
}
