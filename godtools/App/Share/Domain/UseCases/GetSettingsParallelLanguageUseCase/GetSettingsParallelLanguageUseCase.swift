//
//  GetSettingsParallelLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 7/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetSettingsParallelLanguageUseCase {
    
    private let languagesRepository: LanguagesRepository
    private let languageSettingsRepository: LanguageSettingsRepository
    private let getLanguageUseCase: GetLanguageUseCase
    
    init(languagesRepository: LanguagesRepository, languageSettingsRepository: LanguageSettingsRepository, getLanguageUseCase: GetLanguageUseCase) {
        
        self.languagesRepository = languagesRepository
        self.languageSettingsRepository = languageSettingsRepository
        self.getLanguageUseCase = getLanguageUseCase
    }
    
    func getParallelLanguage() -> AnyPublisher<LanguageDomainModel?, Never> {
        
        return Publishers.CombineLatest(languagesRepository.getLanguagesChanged(), languageSettingsRepository.getParallelLanguageChanged())
            .flatMap({ (void: Void, parallelLanguageId: String?) -> AnyPublisher<LanguageDomainModel?, Never> in
                
                guard let parallelLanguageId = parallelLanguageId else {
                    return Just(nil)
                        .eraseToAnyPublisher()
                }
                
                return Just(self.getLanguageUseCase.getLanguage(id: parallelLanguageId))
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
