//
//  GetAccountCreationIsSupportedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAccountCreationIsSupportedUseCase {
    
    private let appBuild: AppBuild
    private let getDeviceLanguageUseCase: GetDeviceLanguageUseCase
    
    init(appBuild: AppBuild, getDeviceLanguageUseCase: GetDeviceLanguageUseCase) {
        
        self.appBuild = appBuild
        self.getDeviceLanguageUseCase = getDeviceLanguageUseCase
    }
    
    func getIsSupportedPublisher() -> AnyPublisher<AccountCreationIsSupportedDomainModel, Never> {
        
        let deviceLanguage: DeviceLanguageDomainModel = getDeviceLanguageUseCase.getDeviceLanguage()
        
        let supportedLanguageCodes: [String] = [LanguageCodeDomainModel.english.value]
        
        let deviceSystemLanguageIsInSupportedLanguageCodes: Bool = supportedLanguageCodes.contains(deviceLanguage.languageCode)
                
        let domainModel = AccountCreationIsSupportedDomainModel(
            isSupported: deviceSystemLanguageIsInSupportedLanguageCodes
        )
        
        return Just(domainModel)
            .eraseToAnyPublisher()
    }
}
