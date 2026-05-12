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
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, getTranslatedLanguageName: GetTranslatedLanguageName, localizationServices: LocalizationServicesInterface, stringWithLocaleCount: StringWithLocaleCountInterface) {
        
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
        
        guard let language = languagesRepository.getLanguage(id: languageId) else {
            return nil
        }
        
        return createLanguageFilterDomainModel(language: language, translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: nil)
    }
    
    func createLanguageFilterDomainModelListPublisher(from languageIds: [String], translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> AnyPublisher<[ToolFilterLanguageDomainModel], Error> {
                
        let anyLanguage = createAnyLanguageDomainModel(
            translatedInAppLanguage: translatedInAppLanguage,
            filteredByCategoryId: filteredByCategoryId
        )
        
        return languagesRepository
            .getLanguagesByIdsPublisher(ids: languageIds)
            .map { (languages: [LanguageDataModel]) in

                let domainModels: [ToolFilterLanguageDomainModel] = languages.compactMap { (language: LanguageDataModel) in
                    
                    let domainModel: ToolFilterLanguageDomainModel = self.createLanguageFilterDomainModel(
                        language: language,
                        translatedInAppLanguage: translatedInAppLanguage,
                        filteredByCategoryId: filteredByCategoryId
                    )
                    
                    guard domainModel.numberOfToolsAvailable > 0 else {
                        return nil
                    }
                    
                    return domainModel
                }
                
                let sortedDomainModels: [ToolFilterLanguageDomainModel] = domainModels
                    .sorted { (thisLanguage: ToolFilterLanguageDomainModel, thatLanguage: ToolFilterLanguageDomainModel) in
                        
                        let thisLanguageName: String = thisLanguage.languageNameTranslatedInAppLanguage
                        let thatLanguageName: String = thatLanguage.languageNameTranslatedInAppLanguage
                        
                        return thisLanguageName.lowercased() < thatLanguageName.lowercased()
                    }
                
                return [anyLanguage] + sortedDomainModels
            }
            .eraseToAnyPublisher()
    }
}

extension GetToolFilterLanguage {
    
    private func createLanguageFilterDomainModel(language: LanguageDataModel, translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> ToolFilterLanguageDomainModel {
        
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
    
    private func createAnyLanguageDomainModel(translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> ToolFilterLanguageDomainModel {
        
        let languageNameTranslatedInAppLanguage: String = localizationServices.stringForLocaleElseSystemElseEnglish(
            localeIdentifier: translatedInAppLanguage.localeId,
            key: ToolStringKeys.ToolFilter.anyLanguageFilterText.rawValue
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
            key: ToolStringKeys.ToolFilter.toolsAvailableText.rawValue
        )
        
        let localizedString: String = stringWithLocaleCount.getString(format: formatString, locale: Locale(identifier: translatedInAppLanguage), count: toolsAvailableCount)
        
        return localizedString
    }
}
