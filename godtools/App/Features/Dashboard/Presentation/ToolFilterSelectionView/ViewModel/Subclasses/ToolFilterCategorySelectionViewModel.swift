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
        
    init(getToolCategoriesUseCase: GetToolCategoriesUseCase, toolFilterSelectionPublisher: CurrentValueSubject<ToolFilterSelection, Never>, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase) {
        
        self.getToolCategoriesUseCase = getToolCategoriesUseCase
        
        super.init(getInterfaceStringInAppLanguageUseCase: getInterfaceStringInAppLanguageUseCase, toolFilterSelectionPublisher: toolFilterSelectionPublisher)
        
        getInterfaceStringInAppLanguageUseCase
            .getStringPublisher(id: ToolStringKeys.ToolFilter.categoryFilterNavTitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: &$navTitle)
        
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
