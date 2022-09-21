//
//  GetSettingsLanguagesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/8/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetSettingsLanguagesUseCase {
    
    private let languagesRepository: LanguagesRepository
    private let getLanguageUseCase: GetLanguageUseCase
    
    init(languagesRepository: LanguagesRepository, getLanguageUseCase: GetLanguageUseCase) {
        
        self.languagesRepository = languagesRepository
        self.getLanguageUseCase = getLanguageUseCase
    }
    
    func getLanguagesList() -> AnyPublisher<[LanguageDomainModel], Never> {
        
        return languagesRepository.getLanguagesChanged()
            .flatMap({ _ -> AnyPublisher<[LanguageDomainModel], Never> in
                
                let languages: [LanguageDomainModel] = self.languagesRepository.getLanguages().map({
                    return self.getLanguageUseCase.getLanguage(language: $0)
                }).sorted(by: {
                    $0.translatedName < $1.translatedName
                })
                
                return Just(languages)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
