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
    
    private let languagesRepository: LanguagesRepository
    private let translatedLanguageNameRepository: TranslatedLanguageNameRepository
    
    init(languagesRepository: LanguagesRepository, translatedLanguageNameRepository: TranslatedLanguageNameRepository) {
        
        self.languagesRepository = languagesRepository
        self.translatedLanguageNameRepository = translatedLanguageNameRepository
    }
    
    func getToolLanguagesPublisher(listType: ToolSettingsToolLanguagesListTypeDomainModel, primaryLanguage: ToolSettingsToolLanguageDomainModel?, parallelLanguage: ToolSettingsToolLanguageDomainModel?, tool: ResourceModel, translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<[ToolSettingsToolLanguageDomainModel], Never> {
        
        var filterOutLanguageIds: [String] = Array()
        
        switch listType {
        case .choosePrimaryLanguage:
            if let parallelLanguage = parallelLanguage {
                filterOutLanguageIds.append(parallelLanguage.dataModelId)
            }
            
        case .chooseParallelLanguage:
            if let primaryLanguage = primaryLanguage {
                filterOutLanguageIds.append(primaryLanguage.dataModelId)
            }
        }
            
        let languageIds: [String] = tool.languageIds.filter({
            !filterOutLanguageIds.contains($0)
        })
        
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
