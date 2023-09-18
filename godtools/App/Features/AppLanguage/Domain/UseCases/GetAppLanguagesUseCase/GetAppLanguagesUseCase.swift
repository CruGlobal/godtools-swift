//
//  GetAppLanguagesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAppLanguagesUseCase {
    
    private static let appLanguages: [LanguageCode] = [.chinese, .english, .french, .latvian, .russian, .spanish, .vietnamese]
    
    private let languagesRepository: LanguagesRepository
    private let getLanguageUseCase: GetLanguageUseCase
    
    init(languagesRepository: LanguagesRepository, getLanguageUseCase: GetLanguageUseCase) {
        
        self.languagesRepository = languagesRepository
        self.getLanguageUseCase = getLanguageUseCase
    }
    
    func getAppLanguagesPublisher() -> AnyPublisher<[LanguageDomainModel], Never> {
                
        return languagesRepository.getLanguagesChanged()
            .map { (void: Void) in
                
                let languages: [LanguageDomainModel] = GetAppLanguagesUseCase.appLanguages.compactMap({
                    self.getLanguageUseCase.getLanguage(languageCode: $0.value)
                })
                
                return languages
            }
            .eraseToAnyPublisher()
    }
}
