//
//  LocalizationServices+GetInterfaceStringRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

extension LocalizationServices: GetInterfaceStringRepositoryInterface {
    
    func getStringForLanguagePublisher(languageCode: String, stringId: String) -> AnyPublisher<String, Never> {
        
        let interfaceString: String = stringForLocaleElseEnglish(localeIdentifier: languageCode, key: stringId)
        
        return Just(interfaceString)
            .eraseToAnyPublisher()
    }
}
