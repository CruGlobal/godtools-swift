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
    private let searchToolFilterCategoriesUseCase: SearchToolFilterCategoriesUseCase
    private let storeUserFiltersUseCase: StoreUserFiltersUseCase
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let categoryFilterSelectionPublisher: CurrentValueSubject<CategoryFilterDomainModel, Never>
    private let selectedLanguage: LanguageFilterDomainModel
    
    private var cancellables: Set<AnyCancellable> = Set()
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var allCategories: [CategoryFilterDomainModel] = [CategoryFilterDomainModel]()
    @Published var searchText: String = ""
    @Published var selectedCategory: CategoryFilterDomainModel
    @Published var navTitle: String = ""
    @Published var categorySearchResults: [CategoryFilterDomainModel] = [CategoryFilterDomainModel]()
    
    init(getToolFilterCategoriesUseCase: GetToolFilterCategoriesUseCase, searchToolFilterCategoriesUseCase: SearchToolFilterCategoriesUseCase, storeUserFiltersUseCase: StoreUserFiltersUseCase, categoryFilterSelectionPublisher: CurrentValueSubject<CategoryFilterDomainModel, Never>, selectedLanguage: LanguageFilterDomainModel, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, flowDelegate: FlowDelegate?) {
        
        self.getToolFilterCategoriesUseCase = getToolFilterCategoriesUseCase
        self.searchToolFilterCategoriesUseCase = searchToolFilterCategoriesUseCase
        self.storeUserFiltersUseCase = storeUserFiltersUseCase
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.categoryFilterSelectionPublisher = categoryFilterSelectionPublisher
        self.selectedLanguage = selectedLanguage
        self.selectedCategory = categoryFilterSelectionPublisher.value
        self.flowDelegate = flowDelegate
        
        getInterfaceStringInAppLanguageUseCase
            .getStringPublisher(id: ToolStringKeys.ToolFilter.categoryFilterNavTitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: &$navTitle)
        
        getToolFilterCategoriesUseCase.getToolFilterCategoriesPublisher(filteredByLanguageId: selectedLanguage.id)
            .receive(on: DispatchQueue.main)
            .assign(to: &$allCategories)
        
        searchToolFilterCategoriesUseCase
            .getSearchResultsPublisher(
                for: $searchText.eraseToAnyPublisher(),
                in: $allCategories.eraseToAnyPublisher()
            )
            .receive(on: DispatchQueue.main)
            .assign(to: &$categorySearchResults)
        
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
            getInterfaceStringInAppLanguageUseCase: getInterfaceStringInAppLanguageUseCase
        )
    }
    
    func rowTapped(with category: CategoryFilterDomainModel) {
        
        selectedCategory = category
        
        storeUserFiltersUseCase.storeCategoryFilterPublisher(with: category.id)
            .sink { _ in
                
            }
            .store(in: &cancellables)
    }
    
    @objc func backButtonTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromToolCategoryFilter)
    }
}
