//
//  ToolFilterCategorySelectionViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ToolFilterCategorySelectionViewModel: ObservableObject {
    
    private let getToolFilterCategoriesUseCase: GetToolFilterCategoriesUseCase
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let categoryFilterSelectionPublisher: CurrentValueSubject<CategoryFilterDomainModel, Never>
    private let searchTextPublisher: CurrentValueSubject<String, Never> = CurrentValueSubject("")
    private let selectedLanguage: LanguageFilterDomainModel
    
    private var allCategories: [CategoryFilterDomainModel] = [CategoryFilterDomainModel]()
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published var selectedCategory: CategoryFilterDomainModel
    @Published var navTitle: String = ""
    @Published var categorySearchResults: [CategoryFilterDomainModel] = [CategoryFilterDomainModel]()
    
    init(getToolFilterCategoriesUseCase: GetToolFilterCategoriesUseCase, categoryFilterSelectionPublisher: CurrentValueSubject<CategoryFilterDomainModel, Never>, selectedLanguage: LanguageFilterDomainModel, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase) {
        
        self.getToolFilterCategoriesUseCase = getToolFilterCategoriesUseCase
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.categoryFilterSelectionPublisher = categoryFilterSelectionPublisher
        self.selectedLanguage = selectedLanguage
        self.selectedCategory = categoryFilterSelectionPublisher.value
        
        getInterfaceStringInAppLanguageUseCase
            .getStringPublisher(id: ToolStringKeys.ToolFilter.categoryFilterNavTitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: &$navTitle)
        
        getToolFilterCategoriesUseCase.getToolFilterCategoriesPublisher(filteredByLanguageId: selectedLanguage.id)
            .sink { [weak self] categories in
                
                self?.allCategories = categories
                self?.getSearchResults()
            }
            .store(in: &cancellables)
        
        searchTextPublisher
            .sink { [weak self] _ in
                
                self?.getSearchResults()
            }
            .store(in: &cancellables)
        
        $selectedCategory
            .sink { [weak self] category in
                
                self?.categoryFilterSelectionPublisher.send(category)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Inputs

extension ToolFilterCategorySelectionViewModel {
    
    func getSearchBarViewModel() -> SearchBarViewModel {
        
        return SearchBarViewModel(
            searchTextPublisher: searchTextPublisher,
            getInterfaceStringInAppLanguageUseCase: getInterfaceStringInAppLanguageUseCase
        )
    }
    
    func rowTapped(with category: CategoryFilterDomainModel) {
        
        selectedCategory = category
    }
}

// MARK: - Private

extension ToolFilterCategorySelectionViewModel {
    
    private func getSearchResults() {
        
        let searchText = searchTextPublisher.value
        
        if searchText.isEmpty == false {
            
            categorySearchResults = self.allCategories.filter { $0.searchableText.contains(searchText) }
            
        } else {
            
            categorySearchResults = self.allCategories
        }
    }
}
