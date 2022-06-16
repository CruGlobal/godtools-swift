//
//  SharedUseCaseType+GetPrimaryLanguageBundleUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

extension SharedUseCaseType {
    
    func getPrimaryLanguageBundle(languageSettingsService: LanguageSettingsService, localizationService: LocalizationServices) -> Bundle {
        
        let bundle: Bundle?
        
        if let primaryLanguageCode = languageSettingsService.primaryLanguage.value?.code {
            bundle = localizationService.bundleLoader.bundleForResource(resourceName: primaryLanguageCode)
        }
        else {
            bundle = nil
        }

        return bundle ?? localizationService.bundleLoader.englishBundle ?? Bundle.main
    }
}
