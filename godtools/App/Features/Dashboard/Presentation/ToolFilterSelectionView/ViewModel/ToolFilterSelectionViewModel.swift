//
//  ToolFilterSelectionViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ToolFilterSelectionViewModel: ObservableObject {
    let localizationServices: LocalizationServices
    let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    let toolFilterSelectionPublisher: CurrentValueSubject<ToolFilterSelection, Never>
    let searchTextPublisher: CurrentValueSubject<String, Never> = CurrentValueSubject("")

    var cancellables: Set<AnyCancellable> = Set()
    
    @Published var navTitle: String = ""
    @Published var rowViewModels: [ToolFilterSelectionRowViewModel] = [ToolFilterSelectionRowViewModel]()
    @Published var filterValueSelected: ToolFilterValue?
    
    var selectedCategory: ToolCategoryDomainModel {
        get {
            return toolFilterSelectionPublisher.value.selectedCategory
            
        } set {
            
            let updatedToolFilterSelection = ToolFilterSelection(
                selectedCategory: newValue,
                selectedLanguage: selectedLanguage
            )
            toolFilterSelectionPublisher.send(updatedToolFilterSelection)
        }
    }
    
    var selectedLanguage: LanguageFilterDomainModel {
        get {
            return toolFilterSelectionPublisher.value.selectedLanguage
            
        } set {
            
            let updatedToolFilterSelection = ToolFilterSelection(
                selectedCategory: selectedCategory,
                selectedLanguage: newValue
            )
            toolFilterSelectionPublisher.send(updatedToolFilterSelection)
        }
    }
    
    init(localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, toolFilterSelectionPublisher: CurrentValueSubject<ToolFilterSelection, Never>) {
        
        self.localizationServices = localizationServices
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.toolFilterSelectionPublisher = toolFilterSelectionPublisher
    }
    
    func rowTapped(with filterValue: ToolFilterValue) {
        
        filterValueSelected = filterValue
        
        switch filterValue {
        case .category(let categoryModel):
            selectedCategory = categoryModel
            
        case .language(let languageModel):
            selectedLanguage = languageModel
        }
    }
}

// MARK: - Inputs

extension ToolFilterSelectionViewModel {
    
    func getSearchBarViewModel() -> SearchBarViewModel {
        
        return SearchBarViewModel(searchTextPublisher: searchTextPublisher, localizationServices: localizationServices)
    }
}
