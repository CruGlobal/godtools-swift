//
//  ArticleCategoryCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ArticleCategoryCellViewModel: ArticleCategoryCellViewModelType {
    
    let articleImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let title: ObservableValue<String?> = ObservableValue(value: "")
    
    required init(category: GodToolsToolParser.Category, manifestResourcesCache: ManifestResourcesCache) {
        
        title.accept(value: category.label?.text ?? "")
        
        if let bannerResource = category.banner, let image = manifestResourcesCache.getUIImage(resource: bannerResource) {
            articleImage.accept(value: image)
        }
    }
}
