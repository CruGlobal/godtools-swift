//
//  GetToolSettingsToolLanguagesListUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetToolSettingsToolLanguagesListUseCase: Sendable {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    
    init(
        resourcesRepository: ResourcesRepository,
        languagesRepository: LanguagesRepository,
        getTranslatedLanguageName: GetTranslatedLanguageName
    ) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedLanguageName = getTranslatedLanguageName
    }
    
    func execute(
        listType: ToolSettingsToolLanguagesListTypeDomainModel,
        primaryLanguageId: String,
        parallelLanguageId: String?,
        toolId: String,
        appLanguage: AppLanguageDomainModel
    ) async throws -> [ToolSettingsToolLanguageDomainModel] {
        
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
        
        if let resource = resourcesRepository.getResourceById(id: toolId) {
            languageIds = resource.languageIds.filter({
                !filterOutLanguageIds.contains($0)
            })
        }
        else {
            languageIds = Array()
        }
        
        let languages: [LanguageDataModel] = try await languagesRepository.getLanguagesByIds(ids: languageIds)
        
        var toolSettingsToolLanguages: [ToolSettingsToolLanguageDomainModel] = Array()
        
        for language in languages {
            
            let languageName: String = await self.getTranslatedLanguageName.getLanguageName(
                language: language,
                translatedInLanguage: appLanguage
            )
            
            let toolLanguage = ToolSettingsToolLanguageDomainModel(
                dataModelId: language.id,
                languageName: languageName
            )
            
            toolSettingsToolLanguages.append(toolLanguage)
        }
        
        return toolSettingsToolLanguages
            .sorted {
                $0.languageName < $1.languageName
            }
    }
}
