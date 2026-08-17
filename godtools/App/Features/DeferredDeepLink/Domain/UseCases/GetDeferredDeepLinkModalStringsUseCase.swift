//
//  GetDeferredDeepLinkModalStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 9/4/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class GetDeferredDeepLinkModalStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface

    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> DeferredDeepLinkModalStringsDomainModel {

        let titleKey: String = LocalizableStringKeys.deferredDeepLinkModalTitle.key
        let messageKey: String = LocalizableStringKeys.deferredDeepLinkModalMessage.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                titleKey,
                messageKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return DeferredDeepLinkModalStringsDomainModel(
            title: strings[titleKey] ?? "",
            message: strings[messageKey] ?? ""
        )
    }
}
