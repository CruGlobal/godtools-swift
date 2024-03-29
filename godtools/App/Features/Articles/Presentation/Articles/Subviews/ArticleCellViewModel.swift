//
//  ArticleCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleCellViewModel {
    
    let title: String?
    
    init(aemData: ArticleAemData) {

        title = aemData.articleJcrContent?.title
    }
}
