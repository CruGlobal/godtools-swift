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
    
    func execute(appLanguage: AppLanguageDomainModel) -> DeleteAccountStringsDomainModel {

        let titleKey: String = LocalizableStringKeys.deleteAccountTitle.key
        let subtitleKey: String = LocalizableStringKeys.deleteAccountSubtitle.key
        let confirmActionTitleKey: String = LocalizableStringKeys.deleteAccountConfirmButtonTitle.key
        let cancelActionTitleKey: String = LocalizableStringKeys.deleteAccountCancelButtonTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                titleKey,
                subtitleKey,
                confirmActionTitleKey,
                cancelActionTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return DeleteAccountStringsDomainModel(
            title: strings[titleKey] ?? "",
            subtitle: strings[subtitleKey] ?? "",
            confirmActionTitle: strings[confirmActionTitleKey] ?? "",
            cancelActionTitle: strings[cancelActionTitleKey] ?? ""
        )
    }
}
