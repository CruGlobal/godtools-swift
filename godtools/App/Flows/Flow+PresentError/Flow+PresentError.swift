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
        
        let localizationServices: LocalizationServices = appDiContainer.dataLayer.getLocalizationServices()
        
        let title: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.error.key)
        let message: String = error.localizedDescription
        
        presentAlert(appLanguage: appLanguage, title: title, message: message)
    }
}
