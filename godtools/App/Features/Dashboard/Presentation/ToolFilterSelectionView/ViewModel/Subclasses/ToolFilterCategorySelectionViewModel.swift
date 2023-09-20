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
        
    init(localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getToolCategoriesUseCase: GetToolCategoriesUseCase, toolFilterSelectionPublisher: CurrentValueSubject<ToolFilterSelection, Never>) {
        
        self.getToolCategoriesUseCase = getToolCategoriesUseCase
        
        super.init(localizationServices: localizationServices, getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase, toolFilterSelectionPublisher: toolFilterSelectionPublisher)
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (primaryLanguage: LanguageDomainModel?) in
                
                let primaryLocaleId: String? = primaryLanguage?.localeIdentifier

                self?.navTitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: primaryLocaleId, key: ToolStringKeys.ToolFilter.categoryFilterNavTitle.rawValue)
            }
            .store(in: &cancellables)
        
        getToolCategoriesUseCase.getToolCategoriesPublisher(filteredByLanguageId: selectedLanguage?.id)
            .sink { [weak self] categories in
                
                self?.categories = categories
                self?.createRowViewModels(from: categories)
            }
            .store(in: &cancellables)
        
        searchTextPublisher
            .sink { [weak self] searchText in
                guard let self = self else { return }
                
                let filteredCategories = self.categories.filter { searchText.isEmpty ? true : $0.translatedName.contains(searchText) }
                self.createRowViewModels(from: filteredCategories)
            }
            .store(in: &cancellables)
        
        if let currentCategorySelected = selectedCategory {
            filterValueSelected = .category(categoryModel: currentCategorySelected)
        }
    }
}

// MARK: - Private

extension ToolFilterCategorySelectionViewModel {
    
    private func createRowViewModels(from categories: [ToolCategoryDomainModel]) {
        
        rowViewModels = categories.map { category in
            
            return ToolFilterSelectionRowViewModel(
                title: category.translatedName,
                subtitle: nil,
                toolsAvailableText: category.toolsAvailableText,
                filterValue: .category(categoryModel: category)
            )
        }        
    }
    
    private func getLanguageLocaleId() -> String? {
        return getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.localeIdentifier
    }
}
