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
    
    private let viewToolFilterCategoriesUseCase: ViewToolFilterCategoriesUseCase
    private let searchToolFilterCategoriesUseCase: SearchToolFilterCategoriesUseCase
    private let storeUserFiltersUseCase: StoreUserFiltersUseCase
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewSearchBarUseCase: ViewSearchBarUseCase
    private let categoryFilterSelectionPublisher: CurrentValueSubject<CategoryFilterDomainModel, Never>
    private let selectedLanguage: LanguageFilterDomainModel
    
    private var cancellables: Set<AnyCancellable> = Set()
    private weak var flowDelegate: FlowDelegate?
    
    let selectedCategory: CategoryFilterDomainModel
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published private var allCategories: [CategoryFilterDomainModel] = [CategoryFilterDomainModel]()
    @Published var searchText: String = ""
    @Published var navTitle: String = ""
    @Published var categorySearchResults: [CategoryFilterDomainModel] = [CategoryFilterDomainModel]()
    
    init(viewToolFilterCategoriesUseCase: ViewToolFilterCategoriesUseCase, searchToolFilterCategoriesUseCase: SearchToolFilterCategoriesUseCase, storeUserFiltersUseCase: StoreUserFiltersUseCase, categoryFilterSelectionPublisher: CurrentValueSubject<CategoryFilterDomainModel, Never>, selectedLanguage: LanguageFilterDomainModel, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewSearchBarUseCase: ViewSearchBarUseCase, flowDelegate: FlowDelegate?) {
        
        self.viewToolFilterCategoriesUseCase = viewToolFilterCategoriesUseCase
        self.searchToolFilterCategoriesUseCase = searchToolFilterCategoriesUseCase
        self.storeUserFiltersUseCase = storeUserFiltersUseCase
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.categoryFilterSelectionPublisher = categoryFilterSelectionPublisher
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewSearchBarUseCase = viewSearchBarUseCase
        self.selectedLanguage = selectedLanguage
        self.selectedCategory = categoryFilterSelectionPublisher.value
        self.flowDelegate = flowDelegate
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap { appLanguage in
                
                return viewToolFilterCategoriesUseCase.viewPublisher(filteredByLanguageId: selectedLanguage.id, translatedInAppLanguage: appLanguage)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewCategoryFiltersDomainModel in
                
                self?.allCategories = viewCategoryFiltersDomainModel.categoryFilters
            }
            .store(in: &cancellables)
        
        getInterfaceStringInAppLanguageUseCase
            .getStringPublisher(id: ToolStringKeys.ToolFilter.categoryFilterNavTitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: &$navTitle)
        
        Publishers.CombineLatest(
            $searchText.eraseToAnyPublisher(),
            $allCategories.eraseToAnyPublisher()
        )
        .flatMap { searchText, allCategories in
            
            searchToolFilterCategoriesUseCase.getSearchResultsPublisher(for: searchText, in: allCategories)
        }
        .receive(on: DispatchQueue.main)
        .assign(to: &$categorySearchResults)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Inputs

extension ToolFilterCategorySelectionViewModel {
    
    func getSearchBarViewModel() -> SearchBarViewModel {
        
        return SearchBarViewModel(
            getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase,
            viewSearchBarUseCase: viewSearchBarUseCase
        )
    }
    
    func rowTapped(with category: CategoryFilterDomainModel) {
                
        categoryFilterSelectionPublisher.send(category)
        
        storeUserFiltersUseCase.storeCategoryFilterPublisher(with: category.id)
            .sink { _ in
                
            }
            .store(in: &cancellables)
        
        flowDelegate?.navigate(step: .categoryTappedFromToolCategoryFilter)
    }
    
    @objc func backButtonTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromToolCategoryFilter)
    }
}
