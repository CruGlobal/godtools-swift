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
    private let translationsRepository: TranslationsRepository
        
    init(getAllToolsUseCase: GetAllToolsUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, localizationServices: LocalizationServices, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository) {
        self.getAllToolsUseCase = getAllToolsUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.localizationServices = localizationServices
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
    }
    
    func getToolCategoriesPublisher(filteredByLanguage: LanguageDomainModel?) -> AnyPublisher<[ToolCategoryDomainModel], Never> {
        
        return Publishers.CombineLatest(
            resourcesRepository.getResourcesChanged(),
            getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
        )
            .flatMap({ _, primaryLanguage -> AnyPublisher<[ToolCategoryDomainModel], Never> in
                
                let categoryIds = self.resourcesRepository
                    .getAllTools(sorted: false, languageId: filteredByLanguage?.id)
                    .getUniqueCategoryIds()
                
                let categories = self.createCategoryDomainModels(from: categoryIds, withTranslation: primaryLanguage, filteredByLanguage: filteredByLanguage)
                
                return Just(categories)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func createCategoryDomainModels(from ids: [String], withTranslation language: LanguageDomainModel?, filteredByLanguage: LanguageDomainModel?) -> [ToolCategoryDomainModel] {
        
        let categories: [ToolCategoryDomainModel] = ids.compactMap { categoryId in
            
            let toolsAvailableCount: Int = getToolsAvailableCount(for: categoryId, filteredByLanguage: filteredByLanguage)
            
            guard toolsAvailableCount > 0 else {
                return nil
            }
            
            let localeId = language?.localeIdentifier
            let translatedName: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tool_category_\(categoryId)")
            
            let toolsAvailableText: String = getToolsAvailableText(toolsAvailableCount: toolsAvailableCount, localeId: localeId)
            
            return ToolCategoryDomainModel(
                id: categoryId,
                translatedName: translatedName,
                toolsAvailableText: toolsAvailableText
            )
        }
        
        return categories
    }
    
    private func getToolsAvailableCount(for categoryId: String, filteredByLanguage: LanguageDomainModel?) -> Int {
        
        return getAllToolsUseCase.getAllTools(
            sorted: false,
            categoryId: categoryId,
            languageId: filteredByLanguage?.id
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
    
    func sortedByPrimaryLanguageAvailable(primaryLanguage: LanguageDomainModel?, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository) -> [ResourceModel] {
        
        guard let primaryLanguageId = primaryLanguage?.id else {
            return self
        }
        
        return sorted(by: { resource1, resource2 in
                        
            func resourceHasTranslation(_ resource: ResourceModel) -> Bool {
                return translationsRepository.getLatestTranslation(resourceId: resource.id, languageId: primaryLanguageId) != nil
            }
            
            func isInDefaultOrder() -> Bool {
                return resource1.attrDefaultOrder < resource2.attrDefaultOrder
            }
            
            if resourceHasTranslation(resource1) {
                
                if resourceHasTranslation(resource2) {
                    return isInDefaultOrder()
                    
                } else {
                    return true
                }
                
            } else if resourceHasTranslation(resource2) {

                return false
                
            } else {
                return isInDefaultOrder()
            }
        })
    }
    
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
