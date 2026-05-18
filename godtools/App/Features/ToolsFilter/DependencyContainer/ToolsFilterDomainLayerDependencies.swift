//
//  ToolsFilterDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class ToolsFilterDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: ToolsFilterDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: ToolsFilterDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getToolFilterCategoriesStringsUseCase() -> GetToolFilterCategoriesStringsUseCase {
        return GetToolFilterCategoriesStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getToolFilterCategoriesUseCase() -> GetToolFilterCategoriesUseCase {
        return GetToolFilterCategoriesUseCase(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            getToolFilterCategory: getToolFilterCategory()
        )
    }
    
    func getToolFilterLanguagesStringsUseCase() -> GetToolFilterLanguagesStringsUseCase {
        return GetToolFilterLanguagesStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getToolFilterLanguagesUseCase() -> GetToolFilterLanguagesUseCase {
        return GetToolFilterLanguagesUseCase(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            getToolFilterLanguage: getToolFilterLanguage()
        )
    }
    
    func getUserToolFilterCategoryUseCase() -> GetUserToolFilterCategoryUseCase {
        return GetUserToolFilterCategoryUseCase(
            userToolFiltersRepository: dataLayer.getUserToolFiltersRepository(),
            getToolFilterCategory: getToolFilterCategory()
        )
    }
    
    func getUserToolFilterLanguageUseCase() -> GetUserToolFilterLanguageUseCase {
        return GetUserToolFilterLanguageUseCase(
            userToolFiltersRepository: dataLayer.getUserToolFiltersRepository(),
            getToolFilterLanguage: getToolFilterLanguage()
        )
    }
    
    func getSearchToolFilterCategoriesUseCase() -> SearchToolFilterCategoriesUseCase {
        return SearchToolFilterCategoriesUseCase(
            stringSearcher: StringSearcher()
        )
    }
    
    func getSearchToolFilterLanguagesUseCase() -> SearchToolFilterLanguagesUseCase {
        return SearchToolFilterLanguagesUseCase(
            stringSearcher: StringSearcher()
        )
    }
    
    func getSelectedToolFilterCategoryUseCase() -> SelectedToolFilterCategoryUseCase {
        return SelectedToolFilterCategoryUseCase(
            userToolFiltersRepository: dataLayer.getUserToolFiltersRepository()
        )
    }
    
    func getSelectedToolFilterLanguageUseCase() -> SelectedToolFilterLanguageUseCase {
        return SelectedToolFilterLanguageUseCase(
            userToolFiltersRepository: dataLayer.getUserToolFiltersRepository()
        )
    }
}

// MARK: - Supporting

extension ToolsFilterDomainLayerDependencies {
    
    private func getToolFilterCategory() -> GetToolFilterCategory {
        return GetToolFilterCategory(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            localizationServices: core.dataLayer.getLocalizationServices(),
            stringWithLocaleCount: core.dataLayer.getStringWithLocaleCount()
        )
    }
    
    private func getToolFilterLanguage() -> GetToolFilterLanguage {
        return GetToolFilterLanguage(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            languagesRepository: core.dataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: core.domainLayer.supporting.getTranslatedLanguageName(),
            localizationServices: core.dataLayer.getLocalizationServices(),
            stringWithLocaleCount: core.dataLayer.getStringWithLocaleCount()
        )
    }
}
