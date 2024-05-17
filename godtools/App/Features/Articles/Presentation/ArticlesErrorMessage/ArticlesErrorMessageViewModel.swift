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
    
    init(appLanguage: AppLanguageDomainModel, localizationServices: LocalizationServices, message: String) {
        
        title = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.downloadError.key)
        self.message = message
        downloadArticlesButtonTitle = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.articlesRetryDownloadButtonTitle.key)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}
