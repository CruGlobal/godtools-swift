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
    
    var selectedCategory: ToolCategoryDomainModel? = nil
    var selectedLanguage: LanguageDomainModel? = nil
    
    let localizationServices: LocalizationServices
    let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    
    var cancellables: Set<AnyCancellable> = Set()
    
    @Published var navTitle: String = ""
    @Published var rowViewModels: [ToolFilterSelectionRowViewModel] = [ToolFilterSelectionRowViewModel]()
    @Published var idSelected: String?
    @Published var searchText = ""
    
    init(toolFilterSelection: ToolFilterSelection, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase) {
        
        self.selectedCategory = toolFilterSelection.selectedCategory
        self.selectedLanguage = toolFilterSelection.selectedLanguage
        
        self.localizationServices = localizationServices
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        
        rowViewModels = [
            ToolFilterSelectionRowViewModel(title: "Hayastan", subtitle: "Armenian", toolsAvailableText: "1 Tools available", filterValueId: "1"),
            ToolFilterSelectionRowViewModel(title: "Hayastan", subtitle: "Armenian", toolsAvailableText: "2 Tools available", filterValueId: "2"),
            ToolFilterSelectionRowViewModel(title: "Hayastan", subtitle: "Armenian", toolsAvailableText: "3 Tools available", filterValueId: "3"),
            ToolFilterSelectionRowViewModel(title: "Hayastan", subtitle: "Armenian", toolsAvailableText: "4 Tools available", filterValueId: "4"),
            ToolFilterSelectionRowViewModel(title: "Hayastan", subtitle: "Armenian", toolsAvailableText: "5 Tools available", filterValueId: "5")
        ]
    }
}
