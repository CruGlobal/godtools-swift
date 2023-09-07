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
    let getAllToolsUseCase: GetAllToolsUseCase
    
    var cancellables: Set<AnyCancellable> = Set()
    
    @Published var navTitle: String = ""
    @Published var rowViewModels: [ToolFilterSelectionRowViewModel] = [ToolFilterSelectionRowViewModel]()
    @Published var idSelected: String?
    @Published var searchText = ""
    
    init(toolFilterSelection: ToolFilterSelection, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getAllToolsUseCase: GetAllToolsUseCase) {
        
        self.selectedCategory = toolFilterSelection.selectedCategory
        self.selectedLanguage = toolFilterSelection.selectedLanguage
        
        self.localizationServices = localizationServices
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getAllToolsUseCase = getAllToolsUseCase
    }    
}
