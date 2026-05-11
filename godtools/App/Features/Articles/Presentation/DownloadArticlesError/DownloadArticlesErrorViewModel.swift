//
//  DownloadArticlesErrorViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@MainActor
final class DownloadArticlesErrorViewModel {
    
    let message: String
    
    init(appLanguage: AppLanguageDomainModel, localizationServices: LocalizationServicesInterface, error: Error) {
            
        if error.isUrlErrorCancelledCode {
            
            message = "The request was cancelled"
        }
        else if error.isUrlErrorNotConnectedToInternetCode {
            
            message = localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: appLanguage,
                key: LocalizableStringKeys.noInternet.key
            )
        }
        else {
            
            message = localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: appLanguage,
                key: LocalizableStringKeys.downloadError.key
            )
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}
