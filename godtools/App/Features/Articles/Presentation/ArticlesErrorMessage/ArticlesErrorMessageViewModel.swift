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
    
    init(localizationServices: LocalizationServices, message: String) {
        
        title = localizationServices.stringForSystemElseEnglish(key: "download_error")
        self.message = message
        downloadArticlesButtonTitle = localizationServices.stringForSystemElseEnglish(key: "articles.downloadArticlesButton.title.retryDownload")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}
