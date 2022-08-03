//
//  GetSettingsPrimaryLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 7/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetSettingsPrimaryLanguageUseCase {
    
    private let languagesRepository: LanguagesRepository
    private let languageSettingsRepository: LanguageSettingsRepository
    private let getDeviceLanguageUseCase: GetDeviceLanguageUseCase
    private let getLanguageUseCase: GetLanguageUseCase
    
    init(languagesRepository: LanguagesRepository, languageSettingsRepository: LanguageSettingsRepository, getDeviceLanguageUseCase: GetDeviceLanguageUseCase, getLanguageUseCase: GetLanguageUseCase) {
        
        self.languagesRepository = languagesRepository
        self.languageSettingsRepository = languageSettingsRepository
        self.getDeviceLanguageUseCase = getDeviceLanguageUseCase
        self.getLanguageUseCase = getLanguageUseCase
    }
    
    func getPrimaryLanguage() -> AnyPublisher<LanguageDomainModel?, Never> {
        
        return Publishers.CombineLatest(languagesRepository.getLanguagesChanged(), languageSettingsRepository.getPrimaryLanguageChanged())
            .flatMap({ (void: Void, primaryLanguageId: String?) -> AnyPublisher<LanguageDomainModel?, Never> in
                
                let language: LanguageDomainModel?
                
                if let primaryLanguageId = primaryLanguageId {

                    language = self.getLanguageUseCase.getLanguage(id: primaryLanguageId)
                }
                else if let deviceLanguage = self.getLanguageUseCase.getLanguage(locale: self.getDeviceLanguageUseCase.getDeviceLanguage().locale) {
                    
                    language = deviceLanguage
                }
                else if let englishLanguage = self.getLanguageUseCase.getLanguage(locale: Locale(identifier: LanguageCodes.english)) {
                    
                    language = englishLanguage
                }
                else {
                    
                    language = nil
                }
                
                return Just(language)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
