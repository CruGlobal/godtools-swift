//
//  GetInterfaceStringUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class GetInterfaceStringUseCase {
        
    private let localizationServices: LocalizationServices
    private let getAppLanguageUseCase: GetAppLanguageUseCase
    
    init(localizationServices: LocalizationServices, getAppLanguageUseCase: GetAppLanguageUseCase) {
        
        self.localizationServices = localizationServices
        self.getAppLanguageUseCase = getAppLanguageUseCase
    }
    
    func getStringValue(id: String) -> String {
        
        let appLanguage: LanguageDomainModel = getAppLanguageUseCase.getLanguageValue()
        
        return localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage.localeIdentifier, key: id)
    }
}
