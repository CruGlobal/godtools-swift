//
//  GetAccountCreationIsSupportedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetAccountCreationIsSupportedUseCase {
    
    private let appBuild: AppBuild
    private let getDeviceLanguageUseCase: GetDeviceLanguageUseCase
    
    init(appBuild: AppBuild, getDeviceLanguageUseCase: GetDeviceLanguageUseCase) {
        
        self.appBuild = appBuild
        self.getDeviceLanguageUseCase = getDeviceLanguageUseCase
    }
    
    func getAccountCreationIsSupported() -> AccountCreationIsSupportedDomainModel {
        
        // TODO: Currently disabled for release builds until we can remove Okta and support social authentication. ~Levi
        
        guard appBuild.configuration != .release else {
            return AccountCreationIsSupportedDomainModel(isSupported: false)
        }
        
        let deviceLanguage: DeviceLanguageDomainModel = getDeviceLanguageUseCase.getDeviceLanguage()
        
        let supportedLanguageCodes: [String] = [LanguageCodes.english]
        
        let deviceSystemLanguageIsInSupportedLanguageCodes: Bool = supportedLanguageCodes.contains(deviceLanguage.localeLanguageCode)
                
        let domainModel = AccountCreationIsSupportedDomainModel(
            isSupported: deviceSystemLanguageIsInSupportedLanguageCodes
        )
        
        return domainModel
    }
}
