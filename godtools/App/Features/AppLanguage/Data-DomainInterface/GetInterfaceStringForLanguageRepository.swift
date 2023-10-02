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

    func getInterfaceStringForLanguagePublisher(appLanguageCode: AppLanguageCodeDomainModel, stringId: String) -> AnyPublisher<String, Never> {
            
        let interfaceString: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageCode, key: stringId)
        
        return Just(interfaceString)
            .eraseToAnyPublisher()
    }
}
