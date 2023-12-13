//
//  GetToolSettingsPrimaryLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolSettingsPrimaryLanguageRepository: GetToolSettingsPrimaryLanguageRepositoryInterface {
    
    private let languagesRepository: LanguagesRepository
    private let localeLanguageName: LocaleLanguageName
    private let localeLanguageScriptName: LocaleLanguageScriptName
    
    init(languagesRepository: LanguagesRepository, localeLanguageName: LocaleLanguageName, localeLanguageScriptName: LocaleLanguageScriptName) {
        
        self.languagesRepository = languagesRepository
        self.localeLanguageName = localeLanguageName
        self.localeLanguageScriptName = localeLanguageScriptName
    }
    
    func getLanguagePublisher() -> AnyPublisher<ToolSettingsToolLanguageDomainModel, Never> {
        
        let language = ToolSettingsToolLanguageDomainModel(dataModelId: "", languageName: "")
        
        return Just(language)
            .eraseToAnyPublisher()
    }
}
