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
    private let localeLanguageName: LocaleLanguageName
    private let localizationServices: LocalizationServices
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, localeLanguageName: LocaleLanguageName, localizationServices: LocalizationServices) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.localeLanguageName = localeLanguageName
        self.localizationServices = localizationServices
    }
    
    func getToolFilterLanguagesPublisher(translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> AnyPublisher<[LanguageFilterDomainModel], Never> {
        
        return resourcesRepository.getResourcesChangedPublisher()
            .flatMap { _ in
                
                let languageIds = self.resourcesRepository
                    .getAllToolsList(filterByCategory: filteredByCategoryId)
                    .getUniqueLanguageIds()
                
                let languages = self.createLanguageFilterDomainModelList(from: Array(languageIds), translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: filteredByCategoryId)
                
                return Just(languages)
            }
            .eraseToAnyPublisher()
    }
    
    func getAnyLanguageFilterDomainModel(translatedInAppLanguage: AppLanguageDomainModel) -> LanguageFilterDomainModel {
        
        return createAnyLanguageDomainModel(translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: nil)
    }
    
    func getLanguageFilter(from languageId: String?, translatedInAppLanguage: AppLanguageDomainModel) -> LanguageFilterDomainModel? {
        
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
    
    private func getLanguageFilterPublisher(from languageId: String?, translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<LanguageFilterDomainModel?, Never> {
        
        guard let languageId = languageId,
              let language = languagesRepository.getLanguage(id: languageId)
        else {
            return Just<LanguageFilterDomainModel?>(nil)
                .eraseToAnyPublisher()
        }
        
        let languageFilter = createLanguageFilterDomainModel(with: language, translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: nil)
        
        return Just<LanguageFilterDomainModel?>(languageFilter)
            .eraseToAnyPublisher()
    }
    
    private func createLanguageFilterDomainModelList(from languageIds: [String], translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> [LanguageFilterDomainModel] {
                
        let anyLanguage = createAnyLanguageDomainModel(translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: filteredByCategoryId)
        
        let languages: [LanguageFilterDomainModel] = languagesRepository.getLanguages(ids: languageIds)
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
        
        return [anyLanguage] + languages
    }
    
    private func createLanguageFilterDomainModel(with languageModel: LanguageModel, translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> LanguageFilterDomainModel {
        
        let toolsAvailableCount: Int = getToolsAvailableCount(for: languageModel.id, filteredByCategoryId: filteredByCategoryId)
        
        let languageName = self.localeLanguageName.getLanguageName(forLanguageCode: languageModel.code, translatedInLanguageId: languageModel.code) ?? ""
        let translatedLanguageName = self.localeLanguageName.getLanguageName(forLanguageCode: languageModel.code, translatedInLanguageId: translatedInAppLanguage) ?? ""
        
        let languageDomainModel = LanguageDomainModel(
            analyticsContentLanguage: languageModel.code,
            dataModelId: languageModel.id,
            direction: languageModel.direction == "rtl" ? .rightToLeft : .leftToRight,
            localeIdentifier: languageModel.code,
            translatedName: translatedLanguageName
        )
        
        let toolsAvailableText: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return .language(
            languageName: languageName,
            toolsAvailableText: toolsAvailableText,
            languageModel: languageDomainModel
        )
    }
    
    private func createAnyLanguageDomainModel(translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> LanguageFilterDomainModel {
        
        let anyLanguageTranslation: String = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: translatedInAppLanguage.localeId, key: ToolStringKeys.ToolFilter.anyLanguageFilterText.rawValue)
        
        let toolsAvailableCount: Int = getToolsAvailableCount(for: nil, filteredByCategoryId: filteredByCategoryId)
        let toolsAvailableText: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return .anyLanguage(
            text: anyLanguageTranslation,
            toolsAvailableText: toolsAvailableText
        )
    }
    
    private func getToolsAvailableCount(for languageCode: BCP47LanguageIdentifier?, filteredByCategoryId: String?) -> Int {
        
        let filter = ResourcesFilter(
            category: filteredByCategoryId,
            languageId: languageCode,
            resourceTypes: ResourceType.toolTypes
        )
        
        return resourcesRepository.getCachedResourcesByFilter(filter: filter).count
    }
    
    private func getToolsAvailableText(toolsAvailableCount: Int, translatedInAppLanguage: AppLanguageDomainModel) -> String {
        
        let formatString = localizationServices.stringForLocaleElseSystemElseEnglish(
            localeIdentifier: translatedInAppLanguage.localeId,
            key: ToolStringKeys.ToolFilter.toolsAvailableText.rawValue,
            fileType: .stringsdict
        )
        
        return String.localizedStringWithFormat(formatString, toolsAvailableCount)
    }
}

// MARK: - ResourceModel Array Extension

private extension Array where Element == ResourceModel {
    
    func getUniqueLanguageIds() -> Set<String> {
        
        let languageIds = flatMap { $0.languageIds }
        
        return Set(languageIds)
    }
}
