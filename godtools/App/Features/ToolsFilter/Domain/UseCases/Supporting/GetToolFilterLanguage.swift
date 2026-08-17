//
//  GetToolFilterLanguage.swift
//  godtools
//
//  Created by Rachael Skeath on 2/27/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolFilterLanguage: Sendable {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    private let localizationServices: LocalizationServicesInterface
    private let stringWithLocaleCount: StringWithLocaleCountInterface
    
    init(
        resourcesRepository: ResourcesRepository,
        languagesRepository: LanguagesRepository,
        getTranslatedLanguageName: GetTranslatedLanguageName,
        localizationServices: LocalizationServicesInterface,
        stringWithLocaleCount: StringWithLocaleCountInterface
    ) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedLanguageName = getTranslatedLanguageName
        self.localizationServices = localizationServices
        self.stringWithLocaleCount = stringWithLocaleCount
    }
    
    func getAnyLanguageFilter(translatedInAppLanguage: AppLanguageDomainModel) -> ToolFilterLanguageDomainModel {
        
        return createAnyLanguageDomainModel(translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: nil)
    }
    
    func getLanguageFilter(languageId: String, translatedInAppLanguage: AppLanguageDomainModel) async -> ToolFilterLanguageDomainModel? {
        
        guard let language = languagesRepository.getLanguageById(id: languageId) else {
            return nil
        }
        
        return await createLanguageFilterDomainModel(language: language, translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: nil)
    }
}

extension GetToolFilterLanguage {
    
    func createLanguageFilterDomainModel(language: LanguageDataModel, translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) async -> ToolFilterLanguageDomainModel {
        
        let toolsAvailableCount: Int = getToolsAvailableCount(languageId: language.id, filteredByCategoryId: filteredByCategoryId)
        
        let languageName = await getTranslatedLanguageName.getLanguageName(language: language, translatedInLanguage: language.code)
        let languageNameTranslatedInAppLanguage = await getTranslatedLanguageName.getLanguageName(language: language, translatedInLanguage: translatedInAppLanguage)
        
        let toolsAvailable: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return ToolFilterLanguageDomainModel.createLanguage(
            id: language.id,
            languageName: languageName,
            languageNameTranslatedInAppLanguage: languageNameTranslatedInAppLanguage,
            toolsAvailable: toolsAvailable,
            numberOfToolsAvailable: toolsAvailableCount
        )
    }
    
    func createAnyLanguageDomainModel(translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> ToolFilterLanguageDomainModel {
        
        let languageNameTranslatedInAppLanguageKey: String = LocalizableStringKeys.toolsFilterAnyLanguage.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                languageNameTranslatedInAppLanguageKey
            ],
            fetchOrder: localizationServices.getDefaultFetchOrder(localeIdentifier: translatedInAppLanguage.localeId),
            shouldFallbackToKey: localizationServices.defaultFallbackToKey
        )

        let languageNameTranslatedInAppLanguage: String = strings[languageNameTranslatedInAppLanguageKey] ?? ""
        
        let toolsAvailableCount: Int = getToolsAvailableCount(languageId: nil, filteredByCategoryId: filteredByCategoryId)
        let toolsAvailable: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return ToolFilterLanguageDomainModel.createAnyLanguage(
            languageNameTranslatedInAppLanguage: languageNameTranslatedInAppLanguage,
            toolsAvailable: toolsAvailable,
            numberOfToolsAvailable: toolsAvailableCount
        )
    }
    
    private func getToolsAvailableCount(languageId: String?, filteredByCategoryId: String?) -> Int {
        
        return resourcesRepository.getAllToolsListCount(filterByCategory: filteredByCategoryId, filterByLanguageId: languageId)
    }
    
    private func getToolsAvailableText(toolsAvailableCount: Int, translatedInAppLanguage: AppLanguageDomainModel) -> String {
        
        let formatStringKey: String = LocalizableStringKeys.toolsFilterToolsAvailable.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                formatStringKey
            ],
            fetchOrder: localizationServices.getDefaultFetchOrder(localeIdentifier: translatedInAppLanguage.localeId),
            shouldFallbackToKey: localizationServices.defaultFallbackToKey
        )

        let formatString: String = strings[formatStringKey] ?? ""
        
        let localizedString: String = stringWithLocaleCount.getString(format: formatString, locale: Locale(identifier: translatedInAppLanguage), count: toolsAvailableCount)
        
        return localizedString
    }
}
