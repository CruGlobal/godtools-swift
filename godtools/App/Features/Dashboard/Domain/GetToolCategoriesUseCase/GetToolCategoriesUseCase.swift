//
//  GetToolCategoriesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Combine

class GetToolCategoriesUseCase {
    
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let localizationServices: LocalizationServices
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
        
    init( getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, localizationServices: LocalizationServices, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository) {
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.localizationServices = localizationServices
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
    }
    
    func getToolCategoriesPublisher() -> AnyPublisher<[ToolCategoryDomainModel], Never> {
        
        return Publishers.CombineLatest(
            resourcesRepository.getResourcesChanged(),
            getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
        )
            .flatMap({ _, primaryLanguage -> AnyPublisher<[ToolCategoryDomainModel], Never> in
                
                let categoryIds = self.resourcesRepository
                    .getAllTools(sorted: false)
                    .sortedByPrimaryLanguageAvailable(primaryLanguage: primaryLanguage, resourcesRepository: self.resourcesRepository, translationsRepository: self.translationsRepository)
                    .getUniqueCategoryIds()
                
                let categories = self.createCategoryDomainModels(from: categoryIds, withTranslation: primaryLanguage)
                
                return Just(categories)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func createCategoryDomainModels(from ids: [String], withTranslation language: LanguageDomainModel?) -> [ToolCategoryDomainModel] {
        
        let categories: [ToolCategoryDomainModel] = ids.map { categoryId in
            
            let translatedName: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: language?.localeIdentifier, key: "tool_category_\(categoryId)")
            
            return ToolCategoryDomainModel(id: categoryId, translatedName: translatedName)
        }
        
        return categories
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
