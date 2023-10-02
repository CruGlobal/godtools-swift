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
        
        getToolCategoriesUseCase.getToolCategoriesPublisher(filteredByLanguageId: selectedLanguage.id)
            .sink { [weak self] categories in
                
                self?.categories = categories
                self?.createRowViewModels()
            }
            .store(in: &cancellables)
        
        searchTextPublisher
            .sink { [weak self] _ in
                
                self?.createRowViewModels()
            }
            .store(in: &cancellables)
        
        filterValueSelected = .category(categoryModel: selectedCategory)
    }
}

// MARK: - Private

extension ToolFilterCategorySelectionViewModel {
    
    private func createRowViewModels() {
        
        let categories: [ToolCategoryDomainModel]
        let searchText = searchTextPublisher.value
        
        if searchText.isEmpty == false {
            
            categories = self.categories.filter { $0.searchableText.contains(searchText) }
            
        } else {
            
            categories = self.categories
        }
        
        rowViewModels = categories.map { category in
            
            return ToolFilterSelectionRowViewModel(
                title: category.translatedName,
                subtitle: nil,
                toolsAvailableText: category.toolsAvailableText,
                filterValue: .category(categoryModel: category)
            )
        }        
    }
}
