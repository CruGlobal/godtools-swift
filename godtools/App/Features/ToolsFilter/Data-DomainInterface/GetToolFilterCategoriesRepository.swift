//
//  GetToolFilterCategoriesRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 2/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolFilterCategoriesRepository: GetToolFilterCategoriesRepositoryInterface {
    
    private let resourcesRepository: ResourcesRepository
    private let localizationServices: LocalizationServices
    private let localeLanguageName: LocaleLanguageName

    init(resourcesRepository: ResourcesRepository, localizationServices: LocalizationServices, localeLanguageName: LocaleLanguageName) {
        
        self.resourcesRepository = resourcesRepository
        self.localizationServices = localizationServices
        self.localeLanguageName = localeLanguageName
    }
    
    func getToolFilterCategoriesPublisher(translatedInAppLanguage: AppLanguageDomainModel, filteredByLanguageId: BCP47LanguageIdentifier?) -> AnyPublisher<[CategoryFilterDomainModel], Never> {
        
        return resourcesRepository.getResourcesChangedPublisher()
            .flatMap { _ in
                
                let categoryIds = self.resourcesRepository
                    .getAllToolsList(filterByLanguageId: filteredByLanguageId, sortByDefaultOrder: false)
                    .getUniqueCategoryIds()
                
                let categories = self.createCategoryDomainModels(from: categoryIds, translatedInAppLanguage: translatedInAppLanguage, filteredByLanguageId: filteredByLanguageId)
                
                return Just(categories)
            }
            .eraseToAnyPublisher()
    }
    
    func getAnyCategoryFilterDomainModel(translatedInAppLanguage: AppLanguageDomainModel) -> CategoryFilterDomainModel {
        
        return createAnyCategoryDomainModel(translatedInAppLanguage: translatedInAppLanguage, filteredByLanguageId: nil)
    }
    
    func getCategoryFilter(from categoryId: String?, translatedInAppLanguage: AppLanguageDomainModel) -> CategoryFilterDomainModel? {
        
        guard let categoryId = categoryId else { return nil }
        
        return createCategoryDomainModel(with: categoryId, translatedInAppLanguage: translatedInAppLanguage, filteredByLanguageId: nil)
    }
}

// MARK: - Private

extension GetToolFilterCategoriesRepository {
    
    private func createCategoryDomainModels(from ids: [String], translatedInAppLanguage: AppLanguageDomainModel, filteredByLanguageId: String?) -> [CategoryFilterDomainModel] {
        
        let anyCategory = createAnyCategoryDomainModel(translatedInAppLanguage: translatedInAppLanguage, filteredByLanguageId: filteredByLanguageId)
        
        let categories: [CategoryFilterDomainModel] = ids.compactMap { categoryId in
            
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
    
    private func createCategoryDomainModel(with categoryId: String, translatedInAppLanguage: AppLanguageDomainModel, filteredByLanguageId: String?) -> CategoryFilterDomainModel {
        
        let toolsAvailableCount: Int = getToolsAvailableCount(for: categoryId, filteredByLanguageId: filteredByLanguageId)
        
        let translatedName: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: translatedInAppLanguage.localeId, key: "tool_category_\(categoryId)")
        
        let toolsAvailableText: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return .category(
            categoryId: categoryId,
            translatedName: translatedName,
            toolsAvailableText: toolsAvailableText
        )
    }
    
    private func createAnyCategoryDomainModel(translatedInAppLanguage: AppLanguageDomainModel, filteredByLanguageId: String?) -> CategoryFilterDomainModel {
        
        let anyCategoryTranslation: String = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: translatedInAppLanguage.localeId, key: ToolStringKeys.ToolFilter.anyCategoryFilterText.rawValue)
    
        let toolsAvailableCount: Int = getToolsAvailableCount(for: nil, filteredByLanguageId: filteredByLanguageId)
        let toolsAvailableText: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, translatedInAppLanguage: translatedInAppLanguage)
        
        return .anyCategory(
            text: anyCategoryTranslation,
            toolsAvailableText: toolsAvailableText
        )
    }
    
    private func getToolsAvailableCount(for categoryId: String?, filteredByLanguageId: String?) -> Int {
        
        let filter = ResourcesFilter(
            category: categoryId,
            languageId: filteredByLanguageId,
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
    
    func getUniqueCategoryIds() -> [String] {
        
        var uniqueCategories = [String]()
        forEach { resource in
            
            let category = resource.attrCategory
            
            if uniqueCategories.contains(category) == false {
                uniqueCategories.append(category)
            }
        }
                
        return uniqueCategories
    }
}
