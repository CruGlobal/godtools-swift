//
//  GetDeferredDeepLinkModalStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 9/4/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetDeferredDeepLinkModalStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface

    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<DeferredDeepLinkModalStringsDomainModel, Never> {
        
        let localeIdentifier = appLanguage
        
        let strings = DeferredDeepLinkModalStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeIdentifier, key: "deferredDeepLinkModal.title"),
            message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeIdentifier, key: "deferredDeepLinkModal.message")
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
