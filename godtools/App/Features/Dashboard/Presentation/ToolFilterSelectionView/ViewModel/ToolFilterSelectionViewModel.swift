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
    let getAllToolsUseCase: GetAllToolsUseCase
    let toolFilterSelectionPublisher: CurrentValueSubject<ToolFilterSelection, Never>
    let searchTextPublisher: CurrentValueSubject<String, Never> = CurrentValueSubject("")

    var cancellables: Set<AnyCancellable> = Set()
    
    @Published var navTitle: String = ""
    @Published var rowViewModels: [ToolFilterSelectionRowViewModel] = [ToolFilterSelectionRowViewModel]()
    @Published var filterValueSelected: ToolFilterValue?
    
    init(localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getAllToolsUseCase: GetAllToolsUseCase, toolFilterSelectionPublisher: CurrentValueSubject<ToolFilterSelection, Never>) {
        
        self.localizationServices = localizationServices
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getAllToolsUseCase = getAllToolsUseCase
        self.toolFilterSelectionPublisher = toolFilterSelectionPublisher
    }
    
    func rowTapped(with filterValue: ToolFilterValue) {
        // overriden in subclasses
    }
}

// MARK: - Inputs

extension ToolFilterSelectionViewModel {
    
    func getSearchBarViewModel() -> SearchBarViewModel {
        
        return SearchBarViewModel(searchTextPublisher: searchTextPublisher, localizationServices: localizationServices)
    }
}
