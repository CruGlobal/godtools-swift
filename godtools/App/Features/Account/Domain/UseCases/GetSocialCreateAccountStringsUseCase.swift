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
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.createAccountTitle.key),
            subtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.createAccountSubtitle.key),
            createWithAppleActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.signInApple.key),
            createWithFacebookActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.signInFacebook.key),
            createWithGoogleActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.signInGoogle.key)
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
