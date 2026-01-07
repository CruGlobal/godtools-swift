//
//  GetToolSettingsToolLanguagesListRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolSettingsToolLanguagesListRepository: GetToolSettingsToolLanguagesListRepositoryInterface {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, getTranslatedLanguageName: GetTranslatedLanguageName) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedLanguageName = getTranslatedLanguageName
    }
    
    @MainActor func getToolLanguagesPublisher(listType: ToolSettingsToolLanguagesListTypeDomainModel, primaryLanguageId: String, parallelLanguageId: String?, toolId: String, translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<[ToolSettingsToolLanguageDomainModel], Error> {
        
        var filterOutLanguageIds: [String] = Array()
        
        switch listType {
        case .choosePrimaryLanguage:
            if let parallelLanguageId = parallelLanguageId {
                filterOutLanguageIds.append(parallelLanguageId)
            }
            
        case .chooseParallelLanguage:
            filterOutLanguageIds.append(primaryLanguageId)
        }
        
        let languageIds: [String]
        
        if let resource = resourcesRepository.persistence.getDataModelNonThrowing(id: toolId) {
            languageIds = resource.getLanguageIds().filter({
                !filterOutLanguageIds.contains($0)
            })
        }
        else {
            languageIds = Array()
        }
        
        return languagesRepository
            .persistence
            .getDataModelsPublisher(getOption: .objectsByIds(ids: languageIds))
            .map { (languages: [LanguageDataModel]) in
                
                let toolSettingsToolLanguages: [ToolSettingsToolLanguageDomainModel] = languages.map { (language: LanguageDataModel) in
                    
                    let languageName: String = self.getTranslatedLanguageName.getLanguageName(
                        language: language,
                        translatedInLanguage: translateInLanguage
                    )
                    
                    return ToolSettingsToolLanguageDomainModel(
                        dataModelId: language.id,
                        languageName: languageName
                    )
                }
                
                return toolSettingsToolLanguages
                    .sorted {
                        $0.languageName < $1.languageName
                    }
            }
            .eraseToAnyPublisher()
    }
}
