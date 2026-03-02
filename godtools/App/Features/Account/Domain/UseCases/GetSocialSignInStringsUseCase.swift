//
//  GetSocialSignInStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetSocialSignInStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<SocialSignInStringsDomainModel, Never> {
        
        let localeId: String = appLanguage
        
        let strings = SocialSignInStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SocialSignIn.signInTitle.rawValue),
            subtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SocialSignIn.signInSubtitle.rawValue),
            signInWithAppleActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SocialSignIn.appleSignIn.rawValue),
            signInWithFacebookActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SocialSignIn.facebookSignIn.rawValue),
            signInWithGoogleActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.SocialSignIn.googleSignIn.rawValue)
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
