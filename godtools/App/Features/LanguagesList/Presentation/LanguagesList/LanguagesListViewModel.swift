//
//  LanguagesListViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class LanguagesListViewModel: BaseLanguagesListViewModel {
    
    required init(languages: [LanguageModel]) {
        
        super.init(languages: languages)
    }
    
    override func getLanguagesListItemViewModel(language: LanguageModel) -> BaseLanguagesListItemViewModel {
        return LanguagesListItemViewModel(language: language)
    }
}
