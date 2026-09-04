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
    
    func getLanguageFilter(languageId: String, translatedInAppLanguage: AppLanguageDomainModel) -> ToolFilterLanguageDomainModel? {
        
        guard let language = languagesRepository.getLanguageById(id: languageId) else {
            return nil
        }
        
        return createLanguageFilterDomainModel(language: language, translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: nil)
    }
}

extension GetToolFilterLanguage {
    
    func createLanguageFilterDomainModel(language: LanguageDataModel, translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> ToolFilterLanguageDomainModel {
        
        let toolsAvailableCount: Int = getToolsAvailableCount(languageId: language.id, filteredByCategoryId: filteredByCategoryId)
        
        let languageNamePair: TranslatedLanguageNamePairDomainModel = getTranslatedLanguageName.getLanguageNamePair(
            language: language,
            appLanguage: translatedInAppLanguage
        )
        
        let toolsAvailable: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return ToolFilterLanguageDomainModel.createLanguage(
            languageId: language.id,
            languageNamePair: languageNamePair,
            toolsAvailableText: toolsAvailable,
            toolsAvailableCount: toolsAvailableCount
        )
    }
    
    func createAnyLanguageDomainModel(translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> ToolFilterLanguageDomainModel {
        
        let anyLanguageNameKey: String = LocalizableStringKeys.toolsFilterAnyLanguage.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                anyLanguageNameKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: translatedInAppLanguage.localeId),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        let nameInAppLanguage: String = strings[anyLanguageNameKey] ?? ""
        
        let toolsAvailableCount: Int = getToolsAvailableCount(languageId: nil, filteredByCategoryId: filteredByCategoryId)
        let toolsAvailable: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return ToolFilterLanguageDomainModel.createAnyLanguage(
            nameInAppLanguage: nameInAppLanguage,
            toolsAvailableText: toolsAvailable,
            toolsAvailableCount: toolsAvailableCount
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
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: translatedInAppLanguage.localeId),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        let formatString: String = strings[formatStringKey] ?? ""
        
        let localizedString: String = stringWithLocaleCount.getString(format: formatString, locale: Locale(identifier: translatedInAppLanguage), count: toolsAvailableCount)
        
        return localizedString
    }
}
