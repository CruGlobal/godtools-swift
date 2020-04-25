//
//  ArticleCategoryCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ArticleCategoryCellViewModel: ArticleCategoryCellViewModelType {
    
    let articleImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let title: ObservableValue<String?> = ObservableValue(value: "")
    
    required init(category: ArticleCategory, godToolsResource: GodToolsResource, resourcesFileCache: ResourcesLatestTranslationsFileCache) {
        
        title.accept(value: category.title)
        
        let cacheLocation = ResourcesLatestTranslationsFileCacheLocation(godToolsResource: godToolsResource)
        switch resourcesFileCache.getData(location: cacheLocation, path: category.bannerSrc) {
            case .success(let bannerImageData):
                if let bannerImageData = bannerImageData {
                    articleImage.accept(value: UIImage(data: bannerImageData))
                }
                else {
                    print("\n \(String(describing: ArticleCategoryCellViewModel.self)) Failed to load banner from cache. Null data.\n  bannerSrc: \(category.bannerSrc)")
                }
            case .failure(let error):
                print("\n \(String(describing: ArticleCategoryCellViewModel.self)) Failed to load banner from cache.\n  bannerSrc: \(category.bannerSrc)\n  error: \(error)")
        }
    }
}
