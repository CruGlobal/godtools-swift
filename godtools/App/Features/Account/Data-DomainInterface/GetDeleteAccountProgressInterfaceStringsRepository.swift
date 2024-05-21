//
//  GetDeleteAccountProgressInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetDeleteAccountProgressInterfaceStringsRepository: GetDeleteAccountProgressInterfaceStringsInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<DeleteAccountProgressInterfaceStringsDomainModel, Never> {
        
        let interfaceStrings = DeleteAccountProgressInterfaceStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInAppLanguage, key: "deleteAccountProgress.title")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
