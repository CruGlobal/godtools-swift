//
//  GetAccountCreationIsSupportedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

final class GetAccountCreationIsSupportedUseCase {
    
    private let supportedLanguageCodes: [String]
        
    init() {
                
        supportedLanguageCodes = [
            LanguageCodeDomainModel.english.rawValue,
            LanguageCodeDomainModel.spanish.rawValue
        ]
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async -> AccountCreationIsSupportedDomainModel {

        let isSupported: Bool = supportedLanguageCodes.contains(appLanguage.languageCode)
                        
        let domainModel = AccountCreationIsSupportedDomainModel(
            isSupported: isSupported
        )
        
        return domainModel
    }
}
