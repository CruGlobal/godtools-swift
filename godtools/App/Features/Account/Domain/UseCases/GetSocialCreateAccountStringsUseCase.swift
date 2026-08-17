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
    
    func execute(appLanguage: AppLanguageDomainModel) -> SocialCreateAccountStringsDomainModel {

        let titleKey: String = LocalizableStringKeys.createAccountTitle.key
        let subtitleKey: String = LocalizableStringKeys.createAccountSubtitle.key
        let createWithAppleActionTitleKey: String = LocalizableStringKeys.signInApple.key
        let createWithFacebookActionTitleKey: String = LocalizableStringKeys.signInFacebook.key
        let createWithGoogleActionTitleKey: String = LocalizableStringKeys.signInGoogle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                titleKey,
                subtitleKey,
                createWithAppleActionTitleKey,
                createWithFacebookActionTitleKey,
                createWithGoogleActionTitleKey
            ],
            fetchOrder: [
                .locale(identifier: appLanguage),
                .english
            ],
            shouldFallbackToKey: true
        )

        return SocialCreateAccountStringsDomainModel(
            title: strings[titleKey] ?? "",
            subtitle: strings[subtitleKey] ?? "",
            createWithAppleActionTitle: strings[createWithAppleActionTitleKey] ?? "",
            createWithFacebookActionTitle: strings[createWithFacebookActionTitleKey] ?? "",
            createWithGoogleActionTitle: strings[createWithGoogleActionTitleKey] ?? ""
        )
    }
}
