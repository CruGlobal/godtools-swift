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
    
    func getPrimaryLanguagePublisher() -> AnyPublisher<LanguageDomainModel?, Never> {
        
        return Publishers.Merge(languagesRepository.getLanguagesChanged(), languageSettingsRepository.getPrimaryLanguageChanged())
            .flatMap { _ in
                
                return Just(self.getPrimaryLanguage())
                    .eraseToAnyPublisher()
            }
            .prepend(getPrimaryLanguage())
            .eraseToAnyPublisher()
    }
    
    func getPrimaryLanguage() -> LanguageDomainModel? {
        
        let language: LanguageDomainModel?
        
        if let primaryLanguageId = languageSettingsRepository.getPrimaryLanguageId() {

            language = self.getLanguageUseCase.getLanguage(id: primaryLanguageId)
        }
        else if let deviceLanguage = self.getLanguageUseCase.getLanguage(languageCode: self.getDeviceLanguageUseCase.getDeviceLanguageValue().languageCode) {
            
            language = deviceLanguage
        }
        else if let englishLanguage = self.getLanguageUseCase.getLanguage(languageCode: LanguageCode.english.value) {
            
            language = englishLanguage
        }
        else {
            
            language = nil
        }
        
        return language
    }
}
