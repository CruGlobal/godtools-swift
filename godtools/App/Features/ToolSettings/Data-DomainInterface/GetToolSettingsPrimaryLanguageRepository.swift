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
    
    private let toolSettingsRepository: ToolSettingsRepository
    private let languagesRepository: LanguagesRepository
    private let getAppLanguageName: GetAppLanguageName
    
    init(toolSettingsRepository: ToolSettingsRepository, languagesRepository: LanguagesRepository, getAppLanguageName: GetAppLanguageName) {
        
        self.toolSettingsRepository = toolSettingsRepository
        self.languagesRepository = languagesRepository
        self.getAppLanguageName = getAppLanguageName
    }
    
    func getLanguagePublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolSettingsToolLanguageDomainModel?, Never> {
        
        return toolSettingsRepository
            .getToolSettingsChangedPublisher()
            .map { _ in
                
                guard let toolSettings = self.toolSettingsRepository.getSharedToolSettings(),
                      let primaryLanguageId = toolSettings.primaryLanguageId,
                      let language = self.languagesRepository.getLanguage(id: primaryLanguageId) else {
                    
                    return nil
                }
                
                let languageName: String = self.getAppLanguageName.getName(
                    languageCode: language.languageCode,
                    scriptCode: language.scriptCode,
                    translatedInLanguage: translateInLanguage
                )
                
                return ToolSettingsToolLanguageDomainModel(
                    dataModelId: language.id,
                    languageName: languageName
                )
            }
            .eraseToAnyPublisher()
    }
}
