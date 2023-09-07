//
//  ToolFilterCategorySelectionViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolFilterCategorySelectionViewModel: ToolFilterSelectionViewModel {
    
    private let getToolCategoriesUseCase: GetToolCategoriesUseCase
    
    private var categories: [ToolCategoryDomainModel] = [ToolCategoryDomainModel]()
        
    init(toolFilterSelection: ToolFilterSelection, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getToolCategoriesUseCase: GetToolCategoriesUseCase, getAllToolsUseCase: GetAllToolsUseCase) {
        
        self.getToolCategoriesUseCase = getToolCategoriesUseCase
        
        super.init(toolFilterSelection: toolFilterSelection, localizationServices: localizationServices, getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase, getAllToolsUseCase: getAllToolsUseCase)
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (primaryLanguage: LanguageDomainModel?) in
                
                let primaryLocaleId: String? = primaryLanguage?.localeIdentifier

                self?.navTitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: primaryLocaleId, key: ToolStringKeys.ToolFilter.categoryFilterNavTitle.rawValue)
            }
            .store(in: &cancellables)
        
        getToolCategoriesUseCase.getToolCategoriesPublisher()
            .sink { [weak self] categories in
                
                self?.categories = categories
                self?.createRowViewModels(from: categories)
            }
            .store(in: &cancellables)
    }
    
    private func createRowViewModels(from categories: [ToolCategoryDomainModel]) {
        
        let localeId = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.localeIdentifier
        let anyCategoryTitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: ToolStringKeys.ToolFilter.anyCategoryFilterText.rawValue)
        
        let anyCategoryViewModel = ToolFilterSelectionRowViewModel(
            title: anyCategoryTitle,
            subtitle: nil,
            toolsAvailableText: getToolsAvailableString(for: nil),
            filterValue: .any
        )
        
        let categoryViewModels = categories.map { category in
            
            return ToolFilterSelectionRowViewModel(
                title: category.translatedName,
                subtitle: nil,
                toolsAvailableText: getToolsAvailableString(for: category.id),
                filterValue: .some(filterValueId: category.id)
            )
        }
        
        rowViewModels = [anyCategoryViewModel] + categoryViewModels
    }
    
    private func getToolsAvailableString(for categoryId: String?) -> String {
        
        let toolsAvailableCount = getAllToolsUseCase.getAllTools(
            sorted: false,
            categoryId: categoryId,
            languageId: selectedLanguage?.id
        ).count
        
        return "\(toolsAvailableCount) tools available"
    }
}
