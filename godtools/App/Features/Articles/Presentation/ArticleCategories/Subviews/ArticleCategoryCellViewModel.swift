//
//  ArticleCategoryCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsShared

class ArticleCategoryCellViewModel {
    
    let articleImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let title: ObservableValue<String?> = ObservableValue(value: "")
    
    init(category: GodToolsShared.Category, manifestResourcesCache: MobileContentRendererManifestResourcesCache) {
        
        title.accept(value: category.label?.text ?? "")
        
        if let bannerResource = category.banner, let image = manifestResourcesCache.getNonThrowingUIImage(resource: bannerResource) {
            articleImage.accept(value: image)
        }
    }
}
