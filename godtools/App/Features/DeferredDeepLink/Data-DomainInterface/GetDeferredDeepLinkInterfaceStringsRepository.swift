//
//  GetDeferredDeepLinkInterfaceStringsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 9/4/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import LocalizationServices

class GetDeferredDeepLinkInterfaceStringsRepository: GetDeferredDeepLinkModalInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServicesInterface

    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<DeferredDeepLinkModalInterfaceStringsDomainModel, Never> {
        
        let localeIdentifier = translateInAppLanguage
        
        let interfaceStrings = DeferredDeepLinkModalInterfaceStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeIdentifier, key: "deferredDeepLinkModal.title"),
            message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeIdentifier, key: "deferredDeepLinkModal.message")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
