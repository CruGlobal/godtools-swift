//
//  ArticleDebugViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ArticleDebugViewModel: ObservableObject {
    
    private let article: ArticleDomainModel
    
    init(article: ArticleDomainModel) {
        
        self.article = article
    }
}
