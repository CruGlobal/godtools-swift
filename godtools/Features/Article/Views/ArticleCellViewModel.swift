//
//  ArticleCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleCellViewModel: ArticleCellViewModelType {
    
    let articleImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let title: ObservableValue<String?> = ObservableValue(value: "")
    
    required init(category: XMLArticleCategory, articleManager: ArticleManager) {
        
        articleImage.accept(value: articleManager.getImage(forCategory: category))
        title.accept(value: articleManager.getTitle(forCategory: category))
    }
}
