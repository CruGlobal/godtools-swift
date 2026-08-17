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
    
    func execute(appLanguage: AppLanguageDomainModel) -> SocialSignInStringsDomainModel {

        let titleKey: String = LocalizableStringKeys.signInTitle.key
        let subtitleKey: String = LocalizableStringKeys.signInSubtitle.key
        let signInWithAppleActionTitleKey: String = LocalizableStringKeys.signInApple.key
        let signInWithFacebookActionTitleKey: String = LocalizableStringKeys.signInFacebook.key
        let signInWithGoogleActionTitleKey: String = LocalizableStringKeys.signInGoogle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                titleKey,
                subtitleKey,
                signInWithAppleActionTitleKey,
                signInWithFacebookActionTitleKey,
                signInWithGoogleActionTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return SocialSignInStringsDomainModel(
            title: strings[titleKey] ?? "",
            subtitle: strings[subtitleKey] ?? "",
            signInWithAppleActionTitle: strings[signInWithAppleActionTitleKey] ?? "",
            signInWithFacebookActionTitle: strings[signInWithFacebookActionTitleKey] ?? "",
            signInWithGoogleActionTitle: strings[signInWithGoogleActionTitleKey] ?? ""
        )
    }
}
