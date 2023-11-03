//
//  GetToolFilterCategoriesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Combine

class GetToolFilterCategoriesUseCase {
    
    private let getAllToolsUseCase: GetAllToolsUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let localizationServices: LocalizationServices
    private let resourcesRepository: ResourcesRepository
        
    init(getAllToolsUseCase: GetAllToolsUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, localizationServices: LocalizationServices, resourcesRepository: ResourcesRepository) {
        self.getAllToolsUseCase = getAllToolsUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.localizationServices = localizationServices
        self.resourcesRepository = resourcesRepository
    }
    
    func getToolFilterCategoriesPublisher(filteredByLanguageId: String?) -> AnyPublisher<[CategoryFilterDomainModel], Never> {
        
        return Publishers.CombineLatest(
            resourcesRepository.getResourcesChangedPublisher(),
            getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
        )
            .flatMap({ _, primaryLanguage -> AnyPublisher<[CategoryFilterDomainModel], Never> in
                
                let categoryIds = self.resourcesRepository
                    .getAllTools(sorted: false, languageId: filteredByLanguageId)
                    .getUniqueCategoryIds()
                
                let categories = self.createCategoryDomainModels(from: categoryIds, withTranslation: primaryLanguage, filteredByLanguageId: filteredByLanguageId)
                
                return Just(categories)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func getAnyCategoryDomainModel() -> CategoryFilterDomainModel {
        
        let translationLocaleId = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.localeIdentifier
        
        return createAnyCategoryDomainModel(translationLocaleId: translationLocaleId, filteredByLanguageId: nil)
    }
    
    private func createCategoryDomainModels(from ids: [String], withTranslation language: LanguageDomainModel?, filteredByLanguageId: String?) -> [CategoryFilterDomainModel] {

        let translationLocaleId: String? = language?.localeIdentifier
        
        let anyCategory = createAnyCategoryDomainModel(translationLocaleId: translationLocaleId, filteredByLanguageId: filteredByLanguageId)
        
        let categories: [CategoryFilterDomainModel] = ids.compactMap { categoryId in
            
            let toolsAvailableCount: Int = getToolsAvailableCount(for: categoryId, filteredByLanguageId: filteredByLanguageId)
            
            guard toolsAvailableCount > 0 else {
                return nil
            }
            
            let translatedName: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: translationLocaleId, key: "tool_category_\(categoryId)")
            
            let toolsAvailableText: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, localeId: translationLocaleId)
            
            return CategoryFilterDomainModel(
                type: .category(id: categoryId),
                translatedName: translatedName,
                toolsAvailableText: toolsAvailableText,
                searchableText: translatedName
            )
        }
        
        return [anyCategory] + categories
    }
    
    private func createAnyCategoryDomainModel(translationLocaleId: String?, filteredByLanguageId: String?) -> CategoryFilterDomainModel {
        
        let anyCategoryTranslation: String = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: translationLocaleId, key: ToolStringKeys.ToolFilter.anyCategoryFilterText.rawValue)
    
        let toolsAvailableCount: Int = getToolsAvailableCount(for: nil, filteredByLanguageId: filteredByLanguageId)
        let toolsAvailableText: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, localeId: translationLocaleId)
        
        return CategoryFilterDomainModel(
            type: .anyCategory,
            translatedName: anyCategoryTranslation,
            toolsAvailableText: toolsAvailableText,
            searchableText: anyCategoryTranslation
        )
    }
    
    private func getToolsAvailableCount(for categoryId: String?, filteredByLanguageId: String?) -> Int {
        
        return getAllToolsUseCase.getAllTools(
            sorted: false,
            optimizeForBatchRequests: true,
            categoryId: categoryId,
            languageId: filteredByLanguageId
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
