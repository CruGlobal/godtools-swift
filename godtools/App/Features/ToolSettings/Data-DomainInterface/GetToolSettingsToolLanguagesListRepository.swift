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
    private let translatedLanguageNameRepository: TranslatedLanguageNameRepository
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, translatedLanguageNameRepository: TranslatedLanguageNameRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.translatedLanguageNameRepository = translatedLanguageNameRepository
    }
    
    func getToolLanguagesPublisher(listType: ToolSettingsToolLanguagesListTypeDomainModel, primaryLanguageId: String, parallelLanguageId: String?, toolId: String, translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<[ToolSettingsToolLanguageDomainModel], Never> {
        
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
        
        if let resource = resourcesRepository.getResource(id: toolId) {
            languageIds = resource.languageIds.filter({
                !filterOutLanguageIds.contains($0)
            })
        }
        else {
            languageIds = Array()
        }
                    
        let toolLanguages: [ToolSettingsToolLanguageDomainModel] = languagesRepository
            .getLanguages(ids: languageIds)
            .map { (language: LanguageModel) in
                                
                let languageName: String = translatedLanguageNameRepository.getLanguageName(
                    language: language,
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
