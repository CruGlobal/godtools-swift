//
//  GetAccountCreationIsSupportedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetAccountCreationIsSupportedUseCase {
    
    private let getDeviceLanguageUseCase: GetDeviceLanguageUseCase
    
    init(getDeviceLanguageUseCase: GetDeviceLanguageUseCase) {
        
        self.getDeviceLanguageUseCase = getDeviceLanguageUseCase
    }
    
    func getAccountCreationIsSupported() -> AccountCreationIsSupportedDomainModel {
        
        let deviceLanguage: DeviceLanguageDomainModel = getDeviceLanguageUseCase.getDeviceLanguage()
        
        let supportedLanguageCodes: [String] = [LanguageCodes.english]
        
        let deviceSystemLanguageIsInSupportedLanguageCodes: Bool = supportedLanguageCodes.contains(deviceLanguage.localeLanguageCode)
                
        let domainModel = AccountCreationIsSupportedDomainModel(
            isSupported: deviceSystemLanguageIsInSupportedLanguageCodes
        )
        
        return domainModel
    }
}
