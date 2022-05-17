//
//  BaseLanguagesListViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class BaseLanguagesListViewModel: ObservableObject {
    
    @Published var languages: [LanguageModel] = Array()
    
    required init(languages: [LanguageModel]) {
        
        self.languages = languages
    }
    
    func getLanguagesListItemViewModel(language: LanguageModel) -> BaseLanguagesListItemViewModel {
        return BaseLanguagesListItemViewModel()
    }
}
