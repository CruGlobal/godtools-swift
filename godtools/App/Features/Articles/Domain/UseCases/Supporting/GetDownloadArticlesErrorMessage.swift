//
//  GetDownloadArticlesErrorMessage.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetDownloadArticlesErrorMessage {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func getErrorMessage(appLanguage: AppLanguageDomainModel, error: Error) -> String {
        
        if error.isUrlErrorCancelledCode {
            
            return "The request was cancelled"
        }
        else if error.isUrlErrorNotConnectedToInternetCode {
            
            return localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: appLanguage,
                key: LocalizableStringKeys.noInternet.key
            )
        }
        else {
            
            return localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: appLanguage,
                key: LocalizableStringKeys.downloadError.key
            )
        }
    }
}
