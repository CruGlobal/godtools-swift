//
//  ArticleCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleCellViewModel: ArticleCellViewModelType {
    
    let title: String?
    
    required init(aemData: ArticleAemData) {
        
        title = aemData.articleJcrContent?.title
    }
}
