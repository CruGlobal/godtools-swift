//
//  ArticlesErrorMessageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/19/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticlesErrorMessageViewModel {
    
    let title: String = NSLocalizedString("articles.downloadingArticles.errorMessage.title", comment: "")
    let message: String
    let downloadArticlesButtonTitle: String = NSLocalizedString("articles.downloadArticlesButton.title.retryDownload", comment: "")
    
    required init(message: String) {
        
        self.message = message
    }
}
