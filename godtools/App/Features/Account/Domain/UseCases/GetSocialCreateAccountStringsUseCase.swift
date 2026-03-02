//
//  GetSocialCreateAccountStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetSocialCreateAccountStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<SocialCreateAccountStringsDomainModel, Never> {
        
        let localeId: String = appLanguage
        
        let strings = SocialCreateAccountStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SocialSignIn.createAccountTitle.rawValue),
            subtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SocialSignIn.createAccountSubtitle.rawValue),
            createWithAppleActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SocialSignIn.appleSignIn.rawValue),
            createWithFacebookActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SocialSignIn.facebookSignIn.rawValue),
            createWithGoogleActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SocialSignIn.googleSignIn.rawValue)
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
