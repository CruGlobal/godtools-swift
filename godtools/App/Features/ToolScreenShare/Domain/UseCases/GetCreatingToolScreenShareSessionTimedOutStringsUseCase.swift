//
//  GetCreatingToolScreenShareSessionTimedOutStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetCreatingToolScreenShareSessionTimedOutStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<CreatingToolScreenShareSessionTimedOutStringsDomainModel, Never> {
        
        let localeId: String = appLanguage
                
        let strings = CreatingToolScreenShareSessionTimedOutStringsDomainModel(
            title: "Timed Out",
            message: "Timed out creating the session for tool screen share.",
            acceptActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "OK"))
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
