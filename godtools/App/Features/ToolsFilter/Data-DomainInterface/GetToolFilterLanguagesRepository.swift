//
//  GetToolFilterLanguagesRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 2/27/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine
import LocalizationServices

class GetToolFilterLanguagesRepository: GetToolFilterLanguagesRepositoryInterface {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    private let localizationServices: LocalizationServices
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, getTranslatedLanguageName: GetTranslatedLanguageName, localizationServices: LocalizationServices) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedLanguageName = getTranslatedLanguageName
        self.localizationServices = localizationServices
    }
    
    func getToolFilterLanguagesPublisher(translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> AnyPublisher<[ToolFilterLanguageDomainModelInterface], Never> {
        
        return resourcesRepository.getResourcesChangedPublisher()
            .flatMap { _ in
                
                let languageIds = self.resourcesRepository
                    .getAllToolLanguageIds(filteredByCategoryId: filteredByCategoryId)
                
                let languages = self.createLanguageFilterDomainModelList(from: languageIds, translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: filteredByCategoryId)
                
                return Just(languages)
            }
            .eraseToAnyPublisher()
    }
    
    func getAnyLanguageFilterDomainModel(translatedInAppLanguage: AppLanguageDomainModel) -> ToolFilterLanguageDomainModelInterface {
        
        return createAnyLanguageDomainModel(translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: nil)
    }
    
    func getLanguageFilter(from languageId: String?, translatedInAppLanguage: AppLanguageDomainModel) -> ToolFilterLanguageDomainModelInterface? {
        
        guard let languageId = languageId,
            let language = languagesRepository.getLanguage(id: languageId)
        else {
            return nil
        }
        
        return createLanguageFilterDomainModel(with: language, translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: nil)
    }
}

// MARK: - Private

extension GetToolFilterLanguagesRepository {
    
    private func getLanguageFilterPublisher(from languageId: String?, translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolFilterLanguageDomainModelInterface?, Never> {
        
        guard let languageId = languageId,
            let language = languagesRepository.getLanguage(id: languageId)
        else {
            return Just<ToolFilterLanguageDomainModelInterface?>(nil)
                .eraseToAnyPublisher()
        }
        
        let languageFilter = createLanguageFilterDomainModel(with: language, translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: nil)
        
        return Just<ToolFilterLanguageDomainModelInterface?>(languageFilter)
            .eraseToAnyPublisher()
    }
    
    private func createLanguageFilterDomainModelList(from languageIds: [String], translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> [ToolFilterLanguageDomainModelInterface] {
                
        let anyLanguage = createAnyLanguageDomainModel(translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: filteredByCategoryId)
        
        let languages: [ToolFilterLanguageDomainModelInterface] = languagesRepository.getLanguages(ids: languageIds)
            .compactMap { languageModel in
                
                let toolsAvailableCount: Int = getToolsAvailableCount(for: languageModel.id, filteredByCategoryId: filteredByCategoryId)
                
                guard toolsAvailableCount > 0 else {
                    return nil
                }
                
                return self.createLanguageFilterDomainModel(
                    with: languageModel,
                    translatedInAppLanguage: translatedInAppLanguage,
                    filteredByCategoryId: filteredByCategoryId
                )
            }
            .sorted { language1, language2 in
                
                let language1Name = language1.translatedName ?? language1.primaryText
                let language2Name = language2.translatedName ?? language2.primaryText
                
                return language1Name.lowercased() < language2Name.lowercased()
            }
        
        return [anyLanguage] + languages
    }
    
    private func createLanguageFilterDomainModel(with languageModel: LanguageModel, translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> ToolFilterLanguageDomainModelInterface {
        
        let toolsAvailableCount: Int = getToolsAvailableCount(for: languageModel.id, filteredByCategoryId: filteredByCategoryId)
        
        let languageName = getTranslatedLanguageName.getLanguageName(language: languageModel, translatedInLanguage: languageModel.code)
        let translatedLanguageName = getTranslatedLanguageName.getLanguageName(language: languageModel, translatedInLanguage: translatedInAppLanguage)
        
        let languageDomainModel = LanguageDomainModel(
            analyticsContentLanguage: languageModel.code,
            dataModelId: languageModel.id,
            direction: languageModel.direction == "rtl" ? .rightToLeft : .leftToRight,
            localeIdentifier: languageModel.code,
            translatedName: translatedLanguageName
        )
        
        let toolsAvailableText: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return ToolFilterLanguageDomainModel(
            languageName: languageName,
            translatedName: languageDomainModel.translatedName,
            toolsAvailableText: toolsAvailableText,
            language: languageDomainModel
        )
    }
    
    private func createAnyLanguageDomainModel(translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> ToolFilterLanguageDomainModelInterface {
        
        let anyLanguageTranslation: String = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: translatedInAppLanguage.localeId, key: ToolStringKeys.ToolFilter.anyLanguageFilterText.rawValue)
        
        let toolsAvailableCount: Int = getToolsAvailableCount(for: nil, filteredByCategoryId: filteredByCategoryId)
        let toolsAvailableText: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return ToolFilterAnyLanguageDomainModel(
            text: anyLanguageTranslation,
            toolsAvailableText: toolsAvailableText
        )
    }
    
    private func getToolsAvailableCount(for languageId: String?, filteredByCategoryId: String?) -> Int {
        
        return resourcesRepository.getAllToolsListCount(filterByCategory: filteredByCategoryId, filterByLanguageId: languageId)
    }
    
    private func getToolsAvailableText(toolsAvailableCount: Int, translatedInAppLanguage: AppLanguageDomainModel) -> String {
        
        let formatString = localizationServices.stringForLocaleElseSystemElseEnglish(
            localeIdentifier: translatedInAppLanguage.localeId,
            key: ToolStringKeys.ToolFilter.toolsAvailableText.rawValue
        )
        
        let localizedString = String(format: formatString, locale: Locale(identifier: translatedInAppLanguage), toolsAvailableCount)
                
        return localizedString
    }
}
