//
//  Flow+PresentError.swift
//  godtools
//
//  Created by Levi Eggert on 5/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import LocalizationServices

extension Flow {
    
    func presentError(appLanguage: AppLanguageDomainModel, error: Error) {
        
        let isCancelled: Bool = error.isUrlErrorCancelledCode || error.isUserCancelled
        
        guard !isCancelled else {
            return
        }

        let localizationServices: LocalizationServices = appDiContainer.dataLayer.getLocalizationServices()
        
        let title: String
        let message: String
        
        if error.isUrlErrorNotConnectedToInternetCode {

            title = localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: appLanguage,
                key: LocalizableStringKeys.noInternetTitle.key
            )
            
            message = localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: appLanguage,
                key: LocalizableStringKeys.noInternet.key
            )
        }
        else if error.isNetworkConnectionLost {
            
            title = localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: appLanguage,
                key: LocalizableStringKeys.noInternetTitle.key
            )
            
            message = localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: appLanguage,
                key: LocalizableStringKeys.networkConnectionLost.key
            )
        }
        else {
            
            title = localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: appLanguage,
                key: LocalizableStringKeys.error.key
            )
            
            message = error.localizedDescription + "\n error code: \(error.code)"
        }
        
        presentAlert(
            appLanguage: appLanguage,
            title: title,
            message: message
        )
    }
}
