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
    private let localizationServices: LocalizationServicesInterface
    private let stringWithLocaleCount: StringWithLocaleCountInterface
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, getTranslatedLanguageName: GetTranslatedLanguageName, localizationServices: LocalizationServicesInterface, stringWithLocaleCount: StringWithLocaleCountInterface) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedLanguageName = getTranslatedLanguageName
        self.localizationServices = localizationServices
        self.stringWithLocaleCount = stringWithLocaleCount
    }
    
    func getToolFilterLanguagesPublisher(translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> AnyPublisher<[ToolFilterLanguageDomainModel], Never> {
        
        return resourcesRepository.observeCollectionChangesPublisher()
            .flatMap { _ in
                
                let languageIds = self.resourcesRepository
                    .getAllToolLanguageIds(filteredByCategoryId: filteredByCategoryId)
                
                let languages = self.createLanguageFilterDomainModelList(from: languageIds, translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: filteredByCategoryId)
                
                return Just(languages)
            }
            .eraseToAnyPublisher()
    }
    
    func getAnyLanguageFilterDomainModel(translatedInAppLanguage: AppLanguageDomainModel) -> ToolFilterLanguageDomainModel {
        
        return createAnyLanguageDomainModel(translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: nil)
    }
    
    func getLanguageFilter(from languageId: String?, translatedInAppLanguage: AppLanguageDomainModel) -> ToolFilterLanguageDomainModel? {
        
        guard let languageId = languageId,
            let language = languagesRepository.getCachedObject(id: languageId)
        else {
            return nil
        }
        
        return createLanguageFilterDomainModel(with: language, translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: nil)
    }
}

// MARK: - Private

extension GetToolFilterLanguagesRepository {
    
    private func getLanguageFilterPublisher(from languageId: String?, translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolFilterLanguageDomainModel?, Never> {
        
        guard let languageId = languageId,
            let language = languagesRepository.getCachedObject(id: languageId)
        else {
            return Just<ToolFilterLanguageDomainModel?>(nil)
                .eraseToAnyPublisher()
        }
        
        let languageFilter = createLanguageFilterDomainModel(with: language, translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: nil)
        
        return Just<ToolFilterLanguageDomainModel?>(languageFilter)
            .eraseToAnyPublisher()
    }
    
    private func createLanguageFilterDomainModelList(from languageIds: [String], translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> [ToolFilterLanguageDomainModel] {
                
        let anyLanguage = createAnyLanguageDomainModel(translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: filteredByCategoryId)
        
        let languages: [ToolFilterLanguageDomainModel] = languagesRepository.getCachedObjects(ids: languageIds)
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
    
    private func createLanguageFilterDomainModel(with languageModel: LanguageDataModel, translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> ToolFilterLanguageDomainModel {
        
        let toolsAvailableCount: Int = getToolsAvailableCount(for: languageModel.id, filteredByCategoryId: filteredByCategoryId)
        
        let languageName = getTranslatedLanguageName.getLanguageName(language: languageModel, translatedInLanguage: languageModel.code)
        let translatedLanguageName = getTranslatedLanguageName.getLanguageName(language: languageModel, translatedInLanguage: translatedInAppLanguage)
        
        let toolsAvailableText: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return ToolFilterLanguageDomainModel(
            languageName: languageName,
            translatedName: translatedLanguageName,
            toolsAvailableText: toolsAvailableText,
            languageId: languageModel.id,
            languageLocaleId: languageModel.code
        )
    }
    
    private func createAnyLanguageDomainModel(translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> ToolFilterLanguageDomainModel {
        
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
        
        let localizedString: String = stringWithLocaleCount.getString(format: formatString, locale: Locale(identifier: translatedInAppLanguage), count: toolsAvailableCount)
        
        return localizedString
    }
}
