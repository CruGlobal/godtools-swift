//
//  GetToolFilterLanguagesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolFilterLanguagesUseCase {
    
    private let getAllToolsUseCase: GetAllToolsUseCase
    private let getLanguageUseCase: GetLanguageUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let languagesRepository: LanguagesRepository
    private let localizationServices: LocalizationServices
    
    init(getAllToolsUseCase: GetAllToolsUseCase, getLanguageUseCase: GetLanguageUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, languagesRepository: LanguagesRepository, localizationServices: LocalizationServices) {
        
        self.getAllToolsUseCase = getAllToolsUseCase
        self.getLanguageUseCase = getLanguageUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.languagesRepository = languagesRepository
        self.localizationServices = localizationServices
    }
    
    func getToolFilterLanguagesPublisher(filteredByCategory: ToolCategoryDomainModel?) -> AnyPublisher<[LanguageFilterDomainModel], Never> {
        
        let languageIds = self.getAllToolsUseCase
            .getAllTools(sorted: false, optimizeForBatchRequests: true, categoryId: filteredByCategory?.id)
            .getUniqueLanguageIds()
        
        let languages = createLanguageFilterDomainModels(from: Array(languageIds), withTranslation: nil, filteredByCategoryId: filteredByCategory?.id)
        
        return Just(languages)
            .eraseToAnyPublisher()
    }
    
    func getAnyLanguageFilterDomainModel() -> LanguageFilterDomainModel {
        
        let translationLocaleId = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.localeIdentifier
        
        return createAnyLanguageDomainModel(translationLocaleId: translationLocaleId, filteredByCategoryId: nil)
    }
    
    private func createLanguageFilterDomainModels(from languageIds: [String], withTranslation translationLanguage: LanguageDomainModel?, filteredByCategoryId: String?) -> [LanguageFilterDomainModel] {
        
        let translationLocaleId: String? = translationLanguage?.localeIdentifier
        
        let anyLanguage = createAnyLanguageDomainModel(translationLocaleId: translationLocaleId, filteredByCategoryId: filteredByCategoryId)
        
        let languages: [LanguageFilterDomainModel] = languagesRepository.getLanguages(ids: languageIds)
            .compactMap { languageModel in
                
                let toolsAvailableCount: Int = getToolsAvailableCount(for: languageModel.id, filteredByCategoryId: filteredByCategoryId)
                
                guard toolsAvailableCount > 0 else {
                    return nil
                }
                
                let languageName = getNameOfLanguage(languageModel)
                let languageDomainModel = getLanguageUseCase.getLanguage(language: languageModel)
                
                let toolsAvailableText: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, localeId: translationLocaleId)
                
                return LanguageFilterDomainModel(
                    type: .language(languageModel: languageDomainModel),
                    languageName: languageName,
                    toolsAvailableText: toolsAvailableText,
                    searchableText: languageDomainModel.translatedName
                )
            }
        
        return [anyLanguage] + languages
    }
    
    private func createAnyLanguageDomainModel(translationLocaleId: String?, filteredByCategoryId: String?) -> LanguageFilterDomainModel {
        
        let anyLanguageTranslation: String = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: translationLocaleId, key: ToolStringKeys.ToolFilter.anyLanguageFilterText.rawValue)
        
        let toolsAvailableCount: Int = getToolsAvailableCount(for: nil, filteredByCategoryId: filteredByCategoryId)
        let toolsAvailableText: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, localeId: translationLocaleId)
        
        return LanguageFilterDomainModel(
            type: .anyLanguage, languageName:
                anyLanguageTranslation,
            toolsAvailableText: toolsAvailableText,
            searchableText: anyLanguageTranslation
        )
    }
    
    private func getToolsAvailableCount(for languageId: String?, filteredByCategoryId: String?) -> Int {
        
        return getAllToolsUseCase.getAllTools(
            sorted: false,
            optimizeForBatchRequests: true,
            categoryId: filteredByCategoryId,
            languageId: languageId
        )
        .count
    }
    
    private func getToolsAvailableText(toolsAvailableCount: Int, localeId: String?) -> String {
        
        let formatString = localizationServices.stringForLocaleElseSystemElseEnglish(
            localeIdentifier: localeId,
            key: ToolStringKeys.ToolFilter.toolsAvailableText.rawValue,
            fileType: .stringsdict
        )
        
        return String.localizedStringWithFormat(formatString, toolsAvailableCount)
    }
    
    private func getNameOfLanguage(_ language: LanguageModel) -> String {
        
        let languageCode = language.code
        let strippedCode: String = languageCode.components(separatedBy: "-x-")[0]

        let localizedKey: String = "language_name_" + languageCode
        let localizedName: String = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: languageCode, key: localizedKey)
        
        var translatedLanguageName: String
        
        if !localizedName.isEmpty && localizedName != localizedKey {
            translatedLanguageName = localizedName
        }
        else if let localeName = Locale.current.localizedString(forIdentifier: strippedCode), !localeName.isEmpty {
            translatedLanguageName = localeName
        }
        else {
            translatedLanguageName = language.name
        }
                        
        if translatedLanguageName.contains(", ") {
            let names: [String] = translatedLanguageName.components(separatedBy: ", ")
            if names.count == 2 {
                translatedLanguageName = names[0] + " (" + names[1] + ")"
            }
        }
                
        return translatedLanguageName
    }
}

// MARK: - ToolDomainModel Array Extension

private extension Array where Element == ToolDomainModel {
    
    func getUniqueLanguageIds() -> Set<String> {
        
        let languageIds = flatMap { $0.languageIds }
        
        return Set(languageIds)
    }
}
