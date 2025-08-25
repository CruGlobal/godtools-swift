//
//  GetCreatingToolScreenShareSessionInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 11/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import LocalizationServices

class GetCreatingToolScreenShareSessionInterfaceStringsRepository: GetCreatingToolScreenShareSessionInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<CreatingToolScreenShareSessionInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInLanguage
        
        let interfaceStrings = CreatingToolScreenShareSessionInterfaceStringsDomainModel(
            creatingSessionMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "load_tool_remote_session.message")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
