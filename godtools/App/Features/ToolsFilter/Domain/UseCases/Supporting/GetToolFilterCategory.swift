//
//  GetToolFilterCategory.swift
//  godtools
//
//  Created by Rachael Skeath on 3/21/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GetToolFilterCategory {
    
    private let resourcesRepository: ResourcesRepository
    private let localizationServices: LocalizationServicesInterface
    private let stringWithLocaleCount: StringWithLocaleCountInterface

    init(resourcesRepository: ResourcesRepository, localizationServices: LocalizationServicesInterface, stringWithLocaleCount: StringWithLocaleCountInterface) {
        
        self.resourcesRepository = resourcesRepository
        self.localizationServices = localizationServices
        self.stringWithLocaleCount = stringWithLocaleCount
    }
    
    func getAnyCategoryFilterDomainModel(translatedInAppLanguage: AppLanguageDomainModel) -> ToolFilterCategoryDomainModel {
        
        return createAnyCategoryDomainModel(translatedInAppLanguage: translatedInAppLanguage, filteredByLanguageId: nil)
    }
    
    func getCategoryFilter(from categoryId: String?, translatedInAppLanguage: AppLanguageDomainModel) -> ToolFilterCategoryDomainModel? {
        
        guard let categoryId = categoryId else {
            return nil
        }
        
        return createCategoryDomainModel(with: categoryId, translatedInAppLanguage: translatedInAppLanguage, filteredByLanguageId: nil)
    }
    
    func createCategoryDomainModels(from ids: [String], translatedInAppLanguage: AppLanguageDomainModel, filteredByLanguageId: String?) -> [ToolFilterCategoryDomainModel] {
        
        let anyCategory = createAnyCategoryDomainModel(translatedInAppLanguage: translatedInAppLanguage, filteredByLanguageId: filteredByLanguageId)
        
        let categories: [ToolFilterCategoryDomainModel] = ids.compactMap { categoryId in
            
            let toolsAvailableCount: Int = getToolsAvailableCount(for: categoryId, filteredByLanguageId: filteredByLanguageId)
            
            guard toolsAvailableCount > 0 else {
                return nil
            }
            
            return self.createCategoryDomainModel(
                with: categoryId,
                translatedInAppLanguage: translatedInAppLanguage,
                filteredByLanguageId: filteredByLanguageId
            )
        }
        
        return [anyCategory] + categories
    }
}

extension GetToolFilterCategory {
    
    private func createCategoryDomainModel(with categoryId: String, translatedInAppLanguage: AppLanguageDomainModel, filteredByLanguageId: String?) -> ToolFilterCategoryDomainModel {
        
        let toolsAvailableCount: Int = getToolsAvailableCount(for: categoryId, filteredByLanguageId: filteredByLanguageId)
        
        let translatedName: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: translatedInAppLanguage.localeId, key: "tool_category_\(categoryId)")
        
        let toolsAvailableText: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return ToolFilterCategoryDomainModel(
            categoryId: categoryId,
            translatedName: translatedName,
            toolsAvailableText: toolsAvailableText
        )
    }
    
    private func createAnyCategoryDomainModel(translatedInAppLanguage: AppLanguageDomainModel, filteredByLanguageId: String?) -> ToolFilterCategoryDomainModel {
        
        let anyCategoryTranslation: String = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: translatedInAppLanguage.localeId, key: ToolStringKeys.ToolFilter.anyCategoryFilterText.rawValue)
    
        let toolsAvailableCount: Int = getToolsAvailableCount(for: nil, filteredByLanguageId: filteredByLanguageId)
        let toolsAvailableText: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return ToolFilterAnyCategoryDomainModel(
            text: anyCategoryTranslation,
            toolsAvailableText: toolsAvailableText
        )
    }
    
    private func getToolsAvailableCount(for categoryId: String?, filteredByLanguageId: String?) -> Int {
        
        return resourcesRepository.getAllToolsListCount(filterByCategory: categoryId, filterByLanguageId: filteredByLanguageId)
    }
    
    private func getToolsAvailableText(toolsAvailableCount: Int, translatedInAppLanguage: AppLanguageDomainModel) -> String {
        
        let formatString = localizationServices.stringForLocaleElseSystemElseEnglish(
            localeIdentifier: translatedInAppLanguage.localeId,
            key: ToolStringKeys.ToolFilter.toolsAvailableText.rawValue
        )
        
        return stringWithLocaleCount.getString(
            format: formatString,
            locale: Locale(identifier: translatedInAppLanguage),
            count: toolsAvailableCount
        )
    }
}
