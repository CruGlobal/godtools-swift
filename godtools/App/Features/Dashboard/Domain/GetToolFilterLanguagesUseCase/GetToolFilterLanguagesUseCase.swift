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
    private let languagesRepository: LanguagesRepository
    private let localizationServices: LocalizationServices
    private let resourcesRepository: ResourcesRepository
    
    init(getAllToolsUseCase: GetAllToolsUseCase, getLanguageUseCase: GetLanguageUseCase, languagesRepository: LanguagesRepository, localizationServices: LocalizationServices, resourcesRepository: ResourcesRepository) {
        
        self.getAllToolsUseCase = getAllToolsUseCase
        self.getLanguageUseCase = getLanguageUseCase
        self.languagesRepository = languagesRepository
        self.localizationServices = localizationServices
        self.resourcesRepository = resourcesRepository
    }
    
    func getToolFilterLanguagesPublisher(filteredByCategory: ToolCategoryDomainModel?) -> AnyPublisher<[LanguageFilterDomainModel], Never> {
        
        let languageIds = self.resourcesRepository
            .getAllTools(sorted: false, category: filteredByCategory?.id)
            .getUniqueLanguageIds()
        
        let languages = createLanguageFilterDomainModels(from: Array(languageIds), withTranslation: nil, filteredByCategory: filteredByCategory)
        
        return Just(languages)
            .eraseToAnyPublisher()
    }
    
    private func createLanguageFilterDomainModels(from languageIds: [String], withTranslation translationLanguage: LanguageDomainModel?, filteredByCategory: ToolCategoryDomainModel?) -> [LanguageFilterDomainModel] {
        
        let translationLocaleId: String? = translationLanguage?.localeIdentifier
        
        return languagesRepository.getLanguages(ids: languageIds)
            .compactMap { languageModel in
                
                let toolsAvailableCount: Int = getToolsAvailableCount(for: languageModel.id, filteredByCategory: filteredByCategory)
                
                guard toolsAvailableCount > 0 else {
                    return nil
                }
                
                let languageName = getNameOfLanguage(languageModel)
                let languageDomainModel = getLanguageUseCase.getLanguage(language: languageModel)
                
                let toolsAvailableText: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, localeId: translationLocaleId)
                
                return LanguageFilterDomainModel(
                    id: languageDomainModel.id,
                    languageName: languageName,
                    translatedName: languageDomainModel.translatedName,
                    toolsAvailableText: toolsAvailableText
                )
            }
    }
    
    private func getToolsAvailableCount(for languageId: String?, filteredByCategory: ToolCategoryDomainModel?) -> Int {
        
        return getAllToolsUseCase.getAllTools(
            sorted: false,
            categoryId: filteredByCategory?.id,
            languageId: languageId
        ).count
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

// MARK: - ResourceModel Array Extension

private extension Array where Element == ResourceModel {
    
    func getUniqueLanguageIds() -> Set<String> {
        
        let languageIds = flatMap { $0.languageIds }
        
        return Set(languageIds)
    }
}
