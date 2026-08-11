//
//  GetDeferredDeepLinkModalStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 9/4/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class GetDeferredDeepLinkModalStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface

    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async -> DeferredDeepLinkModalStringsDomainModel {
        
        let localeIdentifier = appLanguage
        
        let strings = DeferredDeepLinkModalStringsDomainModel(
            title: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeIdentifier, key: LocalizableStringKeys.deferredDeepLinkModalTitle.key),
            message: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeIdentifier, key: LocalizableStringKeys.deferredDeepLinkModalMessage.key)
        )
        
        return strings
    }
}
