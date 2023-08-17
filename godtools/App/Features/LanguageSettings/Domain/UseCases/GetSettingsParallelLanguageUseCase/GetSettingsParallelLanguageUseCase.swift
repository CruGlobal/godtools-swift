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
    
    func getParallelLanguagePublisher() -> AnyPublisher<LanguageDomainModel?, Never> {
        
        return Publishers.CombineLatest(
            languagesRepository.getLanguagesChanged(),
            languageSettingsRepository.getParallelLanguageChanged()
        )
        .flatMap({ (languagesChanged: Void, parallelLanguageId: String?) -> AnyPublisher<LanguageDomainModel?, Never> in
            
            return Just(self.getParallelLanguage())
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
    
    func getParallelLanguage() -> LanguageDomainModel? {
        
        guard let parallelLanguageId = languageSettingsRepository.getParallelLanguageId() else {
            return nil
        }
        
        return getLanguageUseCase.getLanguage(id: parallelLanguageId)
    }
}
