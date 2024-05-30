//
//  Flow+PresentError.swift
//  godtools
//
//  Created by Levi Eggert on 5/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension Flow {
    
    func presentError(appLanguage: AppLanguageDomainModel, error: Error) {
        
        let isCancelled: Bool = error.isUrlErrorCancelledCode || error.isUserCancelled
        
        guard !isCancelled else {
            return
        }

        let localizationServices: LocalizationServices = appDiContainer.dataLayer.getLocalizationServices()
        
        let defaultErrorTitle: String = localizationServices.stringForLocaleElseEnglish(
            localeIdentifier: appLanguage,
            key: LocalizableStringKeys.error.key
        )
        
        let defaultErrorMessage: String = error.localizedDescription
        
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
        else {
            
            title = defaultErrorTitle
            message = defaultErrorMessage
        }
        
        presentAlert(
            appLanguage: appLanguage,
            title: title,
            message: message
        )
    }
}
