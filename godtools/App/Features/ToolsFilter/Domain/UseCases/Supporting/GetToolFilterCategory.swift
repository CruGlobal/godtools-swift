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
    
    func getAnyCategoryFilter(translatedInAppLanguage: AppLanguageDomainModel) -> ToolFilterCategoryDomainModel {
        
        return createAnyCategoryDomainModel(translatedInAppLanguage: translatedInAppLanguage, filteredByLanguageId: nil)
    }
    
    func getCategoryFilter(categoryId: String, translatedInAppLanguage: AppLanguageDomainModel) -> ToolFilterCategoryDomainModel {
        
        return createCategoryDomainModel(categoryId: categoryId, translatedInAppLanguage: translatedInAppLanguage, filteredByLanguageId: nil)
    }
    
    func createCategoryFilters(from ids: [String], translatedInAppLanguage: AppLanguageDomainModel, filteredByLanguageId: String?) -> [ToolFilterCategoryDomainModel] {
        
        let anyCategory = createAnyCategoryDomainModel(translatedInAppLanguage: translatedInAppLanguage, filteredByLanguageId: filteredByLanguageId)
        
        let categories: [ToolFilterCategoryDomainModel] = ids.compactMap { categoryId in
            
            let toolsAvailableCount: Int = getToolsAvailableCount(categoryId: categoryId, filteredByLanguageId: filteredByLanguageId)
            
            guard toolsAvailableCount > 0 else {
                return nil
            }
            
            return self.createCategoryDomainModel(
                categoryId: categoryId,
                translatedInAppLanguage: translatedInAppLanguage,
                filteredByLanguageId: filteredByLanguageId
            )
        }
        
        return [anyCategory] + categories
    }
}

extension GetToolFilterCategory {
    
    private func createAnyCategoryDomainModel(translatedInAppLanguage: AppLanguageDomainModel, filteredByLanguageId: String?) -> ToolFilterCategoryDomainModel {
        
        let title: String = localizationServices.stringForLocaleElseSystemElseEnglish(
            localeIdentifier: translatedInAppLanguage.localeId,
            key: ToolStringKeys.ToolFilter.anyCategoryFilterText.rawValue
        )
    
        let toolsAvailableCount: Int = getToolsAvailableCount(categoryId: nil, filteredByLanguageId: filteredByLanguageId)
        let toolsAvailable: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return ToolFilterCategoryDomainModel.createAnyCategory(title: title, toolsAvailable: toolsAvailable)
    }
    
    private func createCategoryDomainModel(categoryId: String, translatedInAppLanguage: AppLanguageDomainModel, filteredByLanguageId: String?) -> ToolFilterCategoryDomainModel {
        
        let toolsAvailableCount: Int = getToolsAvailableCount(categoryId: categoryId, filteredByLanguageId: filteredByLanguageId)
        
        let translatedName: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: translatedInAppLanguage.localeId, key: "tool_category_\(categoryId)")
        
        let toolsAvailable: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return ToolFilterCategoryDomainModel.createCategory(
            id: categoryId,
            title: translatedName,
            toolsAvailable: toolsAvailable
        )
    }
    
    private func getToolsAvailableCount(categoryId: String?, filteredByLanguageId: String?) -> Int {
        
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
