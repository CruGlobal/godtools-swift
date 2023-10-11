//
//  GetInterfaceStringForLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetInterfaceStringForLanguageRepository: GetInterfaceStringForLanguageRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getString(languageCode: String, stringId: String) -> String {
        
        let interfaceString: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: languageCode, key: stringId)
        
        return interfaceString
    }

    func getStringPublisher(languageCode: String, stringId: String) -> AnyPublisher<String, Never> {
                    
        return Just(getString(languageCode: languageCode, stringId: stringId))
            .eraseToAnyPublisher()
    }
}
