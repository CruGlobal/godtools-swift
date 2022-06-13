//
//  MockLanguagesListViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class MockLanguagesListViewModel: BaseLanguagesListViewModel {
    
    private let selectedLanguageId: String?
    
    init(languages: [ToolLanguageModel], selectedLanguageId: String?) {
        
        self.selectedLanguageId = selectedLanguageId
        
        super.init()
        
        self.languages = languages
    }
    
    override func getLanguagesListItemViewModel(language: ToolLanguageModel) -> BaseLanguagesListItemViewModel {
        
        return MockLanguagesListItemViewModel(language: language, selectedLanguageId: selectedLanguageId)
    }
}
