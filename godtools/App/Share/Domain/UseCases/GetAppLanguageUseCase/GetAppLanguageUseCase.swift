//
//  GetAppLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAppLanguageUseCase {
    
    init() {
        
    }
    
    func getLanguagePublisher() -> AnyPublisher<LanguageDomainModel, Never> {
        
        return Just(getLanguageValue())
            .eraseToAnyPublisher()
    }
    
    func getLanguageValue() -> LanguageDomainModel {
        
        let english = LanguageDomainModel(
            analyticsContentLanguage: "en",
            dataModelId: "1",
            direction: .leftToRight,
            localeIdentifier: "en",
            translatedName: "English"
        )
        
        return english
    }
}
