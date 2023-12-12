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
    
    init(languagesRepository: LanguagesRepository) {
        
        self.languagesRepository = languagesRepository
    }
    
    func getToolLanguagesPublisher(tool: ResourceModel, translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<[ToolSettingsToolLanguageDomainModel], Never> {
        
        let languageIds: [String] = tool.languageIds
        
        let toolLanguages: [ToolSettingsToolLanguageDomainModel] = languagesRepository
            .getLanguages(ids: languageIds)
            .map { (language: LanguageModel) in
                
                let languageName: String = language.code
                
                return ToolSettingsToolLanguageDomainModel(
                    dataModelId: language.id,
                    languageName: languageName
                )
            }
            .sorted {
                $0.languageName < $1.languageName
            }
        
        /*
        return languagesRepository.getLanguages(ids: resource.languageIds)
            .map({ getLanguageUseCase.getLanguage(language: $0) })*/
        
        //let toolLanguages: [ToolSettingsToolLanguageDomainModel] = Array()
        
        return Just(toolLanguages)
            .eraseToAnyPublisher()
    }
}
