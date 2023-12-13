//
//  GetToolSettingsToolLanguagesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolSettingsToolLanguagesRepository: GetToolSettingsToolLanguagesRepositoryInterface {
    
    private let languagesRepository: LanguagesRepository
    private let getAppLanguageName: GetAppLanguageName
    
    init(languagesRepository: LanguagesRepository, localeLanguageName: LocaleLanguageName, localeLanguageScriptName: LocaleLanguageScriptName) {
        
        self.languagesRepository = languagesRepository
        self.getAppLanguageName = GetAppLanguageName(localeLanguageName: localeLanguageName, localeLanguageScriptName: localeLanguageScriptName)
    }
    
    func getToolLanguagesPublisher(tool: ResourceModel, translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<[ToolSettingsToolLanguageDomainModel], Never> {
        
        let languageIds: [String] = tool.languageIds
        
        let toolLanguages: [ToolSettingsToolLanguageDomainModel] = languagesRepository
            .getLanguages(ids: languageIds)
            .map { (language: LanguageModel) in
                                
                let languageName: String = getAppLanguageName.getName(
                    languageCode: language.languageCode,
                    scriptCode: language.scriptCode,
                    translatedInLanguage: translateInLanguage
                )
                
                return ToolSettingsToolLanguageDomainModel(
                    dataModelId: language.id,
                    languageName: languageName
                )
            }
            .sorted {
                $0.languageName < $1.languageName
            }
        
        return Just(toolLanguages)
            .eraseToAnyPublisher()
    }
}
