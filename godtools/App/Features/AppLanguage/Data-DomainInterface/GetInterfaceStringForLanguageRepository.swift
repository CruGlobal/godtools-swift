//
//  GetInterfaceStringForLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class GetInterfaceStringForLanguageRepository: GetInterfaceStringForLanguageRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getInterfaceStringForLanguage(languageCode: AppLanguageCodeDomainModel, stringId: String) -> String {
        
        return localizationServices.stringForLocaleElseEnglish(localeIdentifier: languageCode, key: stringId)
    }
}
