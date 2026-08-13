//
//  GetSocialSignInStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetSocialSignInStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async -> SocialSignInStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let strings = SocialSignInStringsDomainModel(
            title: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.signInTitle.key),
            subtitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.signInSubtitle.key),
            signInWithAppleActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.signInApple.key),
            signInWithFacebookActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.signInFacebook.key),
            signInWithGoogleActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.signInGoogle.key)
        )
        
        return strings
    }
}
