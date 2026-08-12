//
//  GetSocialCreateAccountStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetSocialCreateAccountStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async -> SocialCreateAccountStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let strings = SocialCreateAccountStringsDomainModel(
            title: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.createAccountTitle.key),
            subtitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.createAccountSubtitle.key),
            createWithAppleActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.signInApple.key),
            createWithFacebookActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.signInFacebook.key),
            createWithGoogleActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.signInGoogle.key)
        )
        
        return strings
    }
}
