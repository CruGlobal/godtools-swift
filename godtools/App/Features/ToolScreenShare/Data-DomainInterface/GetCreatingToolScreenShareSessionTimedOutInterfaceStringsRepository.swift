//
//  GetCreatingToolScreenShareSessionTimedOutInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetCreatingToolScreenShareSessionTimedOutInterfaceStringsRepository: GetCreatingToolScreenShareSessionTimedOutInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<CreatingToolScreenShareSessionTimedOutInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInLanguage
        
        let interfaceStrings = CreatingToolScreenShareSessionTimedOutInterfaceStringsDomainModel(
            title: "Timed Out",
            message: "Timed out creating the session for tool screen share.",
            acceptActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "OK"))
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
