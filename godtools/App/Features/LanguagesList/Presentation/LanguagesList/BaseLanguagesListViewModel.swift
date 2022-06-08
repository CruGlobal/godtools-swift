//
//  BaseLanguagesListViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class BaseLanguagesListViewModel: ObservableObject {
    
    @Published var languages: [ToolLanguageModel] = Array()
    
    func getDeleteLanguageListItemViewModel() -> DeleteLanguageListItemViewModel? {
        return nil
    }
    
    func getLanguagesListItemViewModel(language: ToolLanguageModel) -> BaseLanguagesListItemViewModel {
        return BaseLanguagesListItemViewModel()
    }
    
    func closeTapped() {}
    
    func languageTapped(language: ToolLanguageModel) {}
    
    func deleteTapped() {}
}
