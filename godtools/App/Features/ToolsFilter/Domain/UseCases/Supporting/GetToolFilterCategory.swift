//
//  GetToolFilterCategory.swift
//  godtools
//
//  Created by Rachael Skeath on 3/21/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GetToolFilterCategory: Sendable {
    
    private let resourcesRepository: ResourcesRepository
    private let localizationServices: LocalizationServicesInterface
    private let stringWithLocaleCount: StringWithLocaleCountInterface

    init(
        resourcesRepository: ResourcesRepository,
        localizationServices: LocalizationServicesInterface,
        stringWithLocaleCount: StringWithLocaleCountInterface
    ) {
        
        self.resourcesRepository = resourcesRepository
        self.localizationServices = localizationServices
        self.stringWithLocaleCount = stringWithLocaleCount
    }
    
    func getAnyCategoryFilter(translatedInAppLanguage: AppLanguageDomainModel) -> ToolFilterCategoryDomainModel {
        
        return createAnyCategoryDomainModel(translatedInAppLanguage: translatedInAppLanguage, filteredByLanguageId: nil)
    }
    
    func getCategoryFilter(
        categoryId: String,
        translatedInAppLanguage: AppLanguageDomainModel
    ) -> ToolFilterCategoryDomainModel {
        
        return createCategoryDomainModel(
            categoryId: categoryId,
            translatedInAppLanguage: translatedInAppLanguage,
            filteredByLanguageId: nil
        )
    }
    
    func createCategoryFilters(
        from ids: [String],
        translatedInAppLanguage: AppLanguageDomainModel,
        filteredByLanguageId: String?
    ) -> [ToolFilterCategoryDomainModel] {
        
        let anyCategory = createAnyCategoryDomainModel(
            translatedInAppLanguage: translatedInAppLanguage,
            filteredByLanguageId: filteredByLanguageId
        )
        
        var categories: [ToolFilterCategoryDomainModel] = Array()

        for categoryId in ids {

            let toolsAvailableCount: Int = getToolsAvailableCount(
                categoryId: categoryId,
                filteredByLanguageId: filteredByLanguageId
            )

            guard toolsAvailableCount > 0 else {
                continue
            }

            categories.append(
                self.createCategoryDomainModel(
                    categoryId: categoryId,
                    translatedInAppLanguage: translatedInAppLanguage,
                    filteredByLanguageId: filteredByLanguageId
                )
            )
        }

        return [anyCategory] + categories
    }

    func createCategoryFilters(
        from tools: [ResourceDataModel],
        translatedInAppLanguage: AppLanguageDomainModel
    ) -> [ToolFilterCategoryDomainModel] {

        var categoryIds: [String] = Array()
        var toolCountsByCategoryId: [String: Int] = Dictionary()

        for tool in tools where !tool.attrCategory.isEmpty {

            if toolCountsByCategoryId[tool.attrCategory] == nil {
                categoryIds.append(tool.attrCategory)
            }

            toolCountsByCategoryId[tool.attrCategory, default: 0] += 1
        }

        let anyCategory: ToolFilterCategoryDomainModel = createAnyCategoryDomainModel(
            translatedInAppLanguage: translatedInAppLanguage,
            toolsAvailableCount: tools.count
        )

        let categories: [ToolFilterCategoryDomainModel] = categoryIds.map { (categoryId: String) in

            return createCategoryDomainModel(
                categoryId: categoryId,
                translatedInAppLanguage: translatedInAppLanguage,
                toolsAvailableCount: toolCountsByCategoryId[categoryId] ?? 0
            )
        }

        return [anyCategory] + categories
    }
}

extension GetToolFilterCategory {
    
    private func createAnyCategoryDomainModel(
        translatedInAppLanguage: AppLanguageDomainModel,
        filteredByLanguageId: String?
    ) -> ToolFilterCategoryDomainModel {

        return createAnyCategoryDomainModel(
            translatedInAppLanguage: translatedInAppLanguage,
            toolsAvailableCount: getToolsAvailableCount(categoryId: nil, filteredByLanguageId: filteredByLanguageId)
        )
    }

    private func createAnyCategoryDomainModel(
        translatedInAppLanguage: AppLanguageDomainModel,
        toolsAvailableCount: Int
    ) -> ToolFilterCategoryDomainModel {
        
        let titleKey: String = LocalizableStringKeys.toolsFilterAnyCategory.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                titleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: translatedInAppLanguage.localeId),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        let title: String = strings[titleKey] ?? ""
    
        let toolsAvailable: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return ToolFilterCategoryDomainModel.createAnyCategory(title: title, toolsAvailable: toolsAvailable)
    }
    
    private func createCategoryDomainModel(
        categoryId: String,
        translatedInAppLanguage: AppLanguageDomainModel,
        filteredByLanguageId: String?
    ) -> ToolFilterCategoryDomainModel {

        return createCategoryDomainModel(
            categoryId: categoryId,
            translatedInAppLanguage: translatedInAppLanguage,
            toolsAvailableCount: getToolsAvailableCount(categoryId: categoryId, filteredByLanguageId: filteredByLanguageId)
        )
    }

    private func createCategoryDomainModel(
        categoryId: String,
        translatedInAppLanguage: AppLanguageDomainModel,
        toolsAvailableCount: Int
    ) -> ToolFilterCategoryDomainModel {
        
        let translatedNameKey: String = "tool_category_\(categoryId)"

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                translatedNameKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: translatedInAppLanguage.localeId),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        let translatedName: String = strings[translatedNameKey] ?? ""
        
        let toolsAvailable: String = getToolsAvailableText(
            toolsAvailableCount: toolsAvailableCount,
            translatedInAppLanguage: translatedInAppLanguage
        )
        
        return ToolFilterCategoryDomainModel.createCategory(
            id: categoryId,
            title: translatedName,
            toolsAvailable: toolsAvailable
        )
    }
    
    private func getToolsAvailableCount(categoryId: String?, filteredByLanguageId: String?) -> Int {
        
        return resourcesRepository.getAllToolsListCount(
            filterByCategory: categoryId,
            filterByLanguageId: filteredByLanguageId
        )
    }
    
    private func getToolsAvailableText(
        toolsAvailableCount: Int,
        translatedInAppLanguage: AppLanguageDomainModel
    ) -> String {
        
        let formatStringKey: String = LocalizableStringKeys.toolsFilterToolsAvailable.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                formatStringKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: translatedInAppLanguage.localeId),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        let formatString: String = strings[formatStringKey] ?? ""
        
        return stringWithLocaleCount.getString(
            format: formatString,
            locale: Locale(identifier: translatedInAppLanguage),
            count: toolsAvailableCount
        )
    }
}
