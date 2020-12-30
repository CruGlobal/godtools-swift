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
    
    required init(category: ArticleCategory, translationsFileCache: TranslationsFileCache) {
        
        title.accept(value: category.title)
        articleImage.accept(value: translationsFileCache.getImage(location: SHA256FileLocation(sha256WithPathExtension: category.bannerSrc)))
    }
}
