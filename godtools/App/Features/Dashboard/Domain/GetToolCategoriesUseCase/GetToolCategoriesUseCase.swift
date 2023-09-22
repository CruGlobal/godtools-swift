//
//  GetToolCategoriesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Combine

class GetToolCategoriesUseCase {
    
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
    
    func getToolCategoriesPublisher(filteredByLanguageId: String?) -> AnyPublisher<[ToolCategoryDomainModel], Never> {
        
        return Publishers.CombineLatest(
            resourcesRepository.getResourcesChanged(),
            getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
        )
            .flatMap({ _, primaryLanguage -> AnyPublisher<[ToolCategoryDomainModel], Never> in
                
                let categoryIds = self.resourcesRepository
                    .getAllTools(sorted: false, languageId: filteredByLanguageId)
                    .getUniqueCategoryIds()
                
                let categories = self.createCategoryDomainModels(from: categoryIds, withTranslation: primaryLanguage, filteredByLanguageId: filteredByLanguageId)
                
                return Just(categories)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func getAnyCategoryDomainModel() -> ToolCategoryDomainModel {
        
        let translationLocaleId = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.localeIdentifier
        
        return createAnyCategoryDomainModel(translationLocaleId: translationLocaleId, filteredByLanguageId: nil)
    }
    
    private func createCategoryDomainModels(from ids: [String], withTranslation language: LanguageDomainModel?, filteredByLanguageId: String?) -> [ToolCategoryDomainModel] {

        let translationLocaleId: String? = language?.localeIdentifier
        
        let anyCategory = createAnyCategoryDomainModel(translationLocaleId: translationLocaleId, filteredByLanguageId: filteredByLanguageId)
        
        let categories: [ToolCategoryDomainModel] = ids.compactMap { categoryId in
            
            let toolsAvailableCount: Int = getToolsAvailableCount(for: categoryId, filteredByLanguageId: filteredByLanguageId)
            
            guard toolsAvailableCount > 0 else {
                return nil
            }
            
            let translatedName: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: translationLocaleId, key: "tool_category_\(categoryId)")
            
            let toolsAvailableText: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, localeId: translationLocaleId)
            
            return ToolCategoryDomainModel(
                id: categoryId,
                translatedName: translatedName,
                toolsAvailableText: toolsAvailableText
            )
        }
        
        return [anyCategory] + categories
    }
    
    private func createAnyCategoryDomainModel(translationLocaleId: String?, filteredByLanguageId: String?) -> ToolCategoryDomainModel {
        
        let anyCategoryTranslation: String = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: translationLocaleId, key: ToolStringKeys.ToolFilter.anyCategoryFilterText.rawValue)
    
        let toolsAvailableCount: Int = getToolsAvailableCount(for: nil, filteredByLanguageId: filteredByLanguageId)
        let toolsAvailableText: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, localeId: translationLocaleId)
        
        return ToolCategoryDomainModel(
            id: nil,
            translatedName: anyCategoryTranslation,
            toolsAvailableText: toolsAvailableText
        )
    }
    
    private func getToolsAvailableCount(for categoryId: String?, filteredByLanguageId: String?) -> Int {
        
        return getAllToolsUseCase.getAllTools(
            sorted: false,
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
