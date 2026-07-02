//
//  GetToolFilterLanguage.swift
//  godtools
//
//  Created by Rachael Skeath on 2/27/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolFilterLanguage {
    
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
        
        let languageName = getTranslatedLanguageName.getLanguageName(language: language, translatedInLanguage: language.code)
        let languageNameTranslatedInAppLanguage = getTranslatedLanguageName.getLanguageName(language: language, translatedInLanguage: translatedInAppLanguage)
        
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
        
        let languageNameTranslatedInAppLanguage: String = localizationServices.stringForLocaleElseSystemElseEnglish(
            localeIdentifier: translatedInAppLanguage.localeId,
            key: LocalizableStringKeys.toolsFilterAnyLanguage.key
        )
        
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
        
        let formatString = localizationServices.stringForLocaleElseSystemElseEnglish(
            localeIdentifier: translatedInAppLanguage.localeId,
            key: LocalizableStringKeys.toolsFilterToolsAvailable.key
        )
        
        let localizedString: String = stringWithLocaleCount.getString(format: formatString, locale: Locale(identifier: translatedInAppLanguage), count: toolsAvailableCount)
        
        return localizedString
    }
}
