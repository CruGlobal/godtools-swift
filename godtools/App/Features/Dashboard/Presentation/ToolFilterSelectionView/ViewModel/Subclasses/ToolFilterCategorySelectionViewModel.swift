//
//  ToolFilterCategorySelectionViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ToolFilterCategorySelectionViewModel: ToolFilterSelectionViewModel {
    
    private let getToolCategoriesUseCase: GetToolCategoriesUseCase
    
    private var categories: [ToolCategoryDomainModel] = [ToolCategoryDomainModel]()
        
    init(localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getToolCategoriesUseCase: GetToolCategoriesUseCase, getAllToolsUseCase: GetAllToolsUseCase, toolFilterSelectionPublisher: CurrentValueSubject<ToolFilterSelection, Never>) {
        
        self.getToolCategoriesUseCase = getToolCategoriesUseCase
        
        super.init(localizationServices: localizationServices, getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase, getAllToolsUseCase: getAllToolsUseCase, toolFilterSelectionPublisher: toolFilterSelectionPublisher)
        
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
        
        if let currentCategorySelected = toolFilterSelectionPublisher.value.selectedCategory {
            filterValueSelected = .category(categoryModel: currentCategorySelected)
        } else {
            filterValueSelected = .any
        }
    }
    
    override func rowTapped(with filterValue: ToolFilterValue) {
        
        filterValueSelected = filterValue
        let selectedCategory: ToolCategoryDomainModel?
        
        switch filterValue {
        case .category(let categoryModel):
            selectedCategory = categoryModel
            
        case .any:
            selectedCategory = nil
            
        default:
            return
        }
        
        let currentLanguage = toolFilterSelectionPublisher.value.selectedLanguage
        let toolFilterSelection = ToolFilterSelection(
            selectedCategory: selectedCategory,
            selectedLanguage: currentLanguage
            )
        
        toolFilterSelectionPublisher.send(toolFilterSelection)
    }
}

// MARK: - Private

extension ToolFilterCategorySelectionViewModel {
    
    private func createRowViewModels(from categories: [ToolCategoryDomainModel]) {
        
        let anyCategoryTitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: getLanguageLocaleId(), key: ToolStringKeys.ToolFilter.anyCategoryFilterText.rawValue)
        
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
                filterValue: .category(categoryModel: category)
            )
        }
        
        rowViewModels = [anyCategoryViewModel] + categoryViewModels
    }
    
    private func getToolsAvailableString(for categoryId: String?) -> String {
        
        let toolsAvailableCount = getAllToolsUseCase.getAllTools(
            sorted: false,
            categoryId: categoryId,
            languageId: toolFilterSelectionPublisher.value.selectedLanguage?.id
        ).count
        
        let formatString = localizationServices.stringForLocaleElseSystemElseEnglish(
            localeIdentifier: getLanguageLocaleId(),
            key: ToolStringKeys.ToolFilter.toolsAvailableText.rawValue,
            fileType: .stringsdict
        )
        
        return String.localizedStringWithFormat(formatString, toolsAvailableCount)
    }
    
    private func getLanguageLocaleId() -> String? {
        return getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.localeIdentifier
    }
}
