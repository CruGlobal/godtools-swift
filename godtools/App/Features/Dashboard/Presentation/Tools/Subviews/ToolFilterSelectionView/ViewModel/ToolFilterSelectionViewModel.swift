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
    
    init(toolFilterSelection: ToolFilterSelection, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase) {
        
        self.selectedCategory = toolFilterSelection.selectedCategory
        self.selectedLanguage = toolFilterSelection.selectedLanguage
        
        self.localizationServices = localizationServices
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
    }
    
}

// MARK: - Inputs

extension ToolFilterSelectionViewModel {
    
    func getToolFilterSelectionRowViewModel() -> ToolFilterSelectionRowViewModel {
        
        return ToolFilterSelectionRowViewModel(title: "Hayastan", subtitle: "Armenian", toolsAvailableText: "7 Tools available")
    }
}
