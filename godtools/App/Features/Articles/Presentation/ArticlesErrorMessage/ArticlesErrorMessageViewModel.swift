//
//  ArticlesErrorMessageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/19/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticlesErrorMessageViewModel {
    
    let title: String
    let message: String
    let downloadArticlesButtonTitle: String
    
    required init(localizationServices: LocalizationServices, message: String) {
        
        title = localizationServices.stringForMainBundle(key: "download_error")
        self.message = message
        downloadArticlesButtonTitle = localizationServices.stringForMainBundle(key: "articles.downloadArticlesButton.title.retryDownload")
    }
}