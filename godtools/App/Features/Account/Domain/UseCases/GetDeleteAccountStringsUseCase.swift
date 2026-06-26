//
//  GetDeleteAccountStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GetDeleteAccountStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> DeleteAccountStringsDomainModel {
        
        let strings = DeleteAccountStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.deleteAccountTitle.key),
            subtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.deleteAccountSubtitle.key),
            confirmActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.deleteAccountConfirmButtonTitle.key),
            cancelActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.deleteAccountCancelButtonTitle.key)
        )
        
        return strings
    }
}
