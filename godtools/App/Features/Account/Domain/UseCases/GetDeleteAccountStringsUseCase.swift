//
//  GetDeleteAccountStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GetDeleteAccountStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async -> DeleteAccountStringsDomainModel {
        
        let strings = DeleteAccountStringsDomainModel(
            title: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.deleteAccountTitle.key),
            subtitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.deleteAccountSubtitle.key),
            confirmActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.deleteAccountConfirmButtonTitle.key),
            cancelActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.deleteAccountCancelButtonTitle.key)
        )
        
        return strings
    }
}
