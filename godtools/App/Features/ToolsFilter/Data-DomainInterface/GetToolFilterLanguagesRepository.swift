//
//  GetToolFilterLanguagesRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 2/27/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

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
    
    @MainActor func getToolFilterLanguagesPublisher(translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> AnyPublisher<[ToolFilterLanguageDomainModel], Error> {
        
        return resourcesRepository
            .persistence
            .observeCollectionChangesPublisher()
            .flatMap { _ in
                
                let languageIds = self.resourcesRepository
                    .getAllToolLanguageIds(filteredByCategoryId: filteredByCategoryId)
                
                return self.createLanguageFilterDomainModelListPublisher(
                    from: languageIds,
                    translatedInAppLanguage: translatedInAppLanguage,
                    filteredByCategoryId: filteredByCategoryId
                )
            }
            .eraseToAnyPublisher()
    }
    
    func getAnyLanguageFilterDomainModel(translatedInAppLanguage: AppLanguageDomainModel) -> ToolFilterLanguageDomainModel {
        
        return createAnyLanguageDomainModel(translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: nil)
    }
    
    func getLanguageFilter(from languageId: String?, translatedInAppLanguage: AppLanguageDomainModel) -> ToolFilterLanguageDomainModel? {
        
        guard let languageId = languageId,
            let language = languagesRepository.persistence.getDataModelNonThrowing(id: languageId)
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
            let language = languagesRepository.persistence.getDataModelNonThrowing(id: languageId)
        else {
            return Just<ToolFilterLanguageDomainModel?>(nil)
                .eraseToAnyPublisher()
        }
        
        let languageFilter = createLanguageFilterDomainModel(with: language, translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: nil)
        
        return Just<ToolFilterLanguageDomainModel?>(languageFilter)
            .eraseToAnyPublisher()
    }
    
    private func createLanguageFilterDomainModelListPublisher(from languageIds: [String], translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> AnyPublisher<[ToolFilterLanguageDomainModel], Error> {
                
        let anyLanguage = createAnyLanguageDomainModel(
            translatedInAppLanguage: translatedInAppLanguage,
            filteredByCategoryId: filteredByCategoryId
        )
        
        return languagesRepository
            .persistence
            .getDataModelsPublisher(getOption: .objectsByIds(ids: languageIds))
            .map { (languages: [LanguageDataModel]) in

                let domainModels: [ToolFilterLanguageDomainModel] = languages.compactMap { (language: LanguageDataModel) in
                    
                    let domainModel: ToolFilterLanguageDomainModel = self.createLanguageFilterDomainModel(
                        with: language,
                        translatedInAppLanguage: translatedInAppLanguage,
                        filteredByCategoryId: filteredByCategoryId
                    )
                    
                    guard domainModel.numberOfToolsAvailable > 0 else {
                        return nil
                    }
                    
                    return domainModel
                }
                
                let sortedDomainModels: [ToolFilterLanguageDomainModel] = domainModels
                    .sorted { language1, language2 in
                        
                        let language1Name = language1.translatedName ?? language1.primaryText
                        let language2Name = language2.translatedName ?? language2.primaryText
                        
                        return language1Name.lowercased() < language2Name.lowercased()
                    }
                
                return [anyLanguage] + sortedDomainModels
            }
            .eraseToAnyPublisher()
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
            languageLocaleId: languageModel.code,
            numberOfToolsAvailable: toolsAvailableCount
        )
    }
    
    private func createAnyLanguageDomainModel(translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> ToolFilterLanguageDomainModel {
        
        let anyLanguageTranslation: String = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: translatedInAppLanguage.localeId, key: ToolStringKeys.ToolFilter.anyLanguageFilterText.rawValue)
        
        let toolsAvailableCount: Int = getToolsAvailableCount(for: nil, filteredByCategoryId: filteredByCategoryId)
        let toolsAvailableText: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return ToolFilterAnyLanguageDomainModel(
            text: anyLanguageTranslation,
            toolsAvailableText: toolsAvailableText,
            numberOfToolsAvailable: toolsAvailableCount
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
