//
//  GetSocialCreateAccountInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 11/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetSocialCreateAccountInterfaceStringsRepository: GetSocialCreateAccountInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<SocialCreateAccountInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInLanguage
        
        let interfaceStrings = SocialCreateAccountInterfaceStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SocialSignIn.createAccountTitle.rawValue),
            subtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SocialSignIn.createAccountSubtitle.rawValue),
            createWithAppleActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SocialSignIn.appleSignIn.rawValue),
            createWithFacebookActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SocialSignIn.facebookSignIn.rawValue),
            createWithGoogleActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SocialSignIn.googleSignIn.rawValue)
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
