//
//  MockLanguagesListItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class MockLanguagesListItemViewModel: BaseLanguagesListItemViewModel {
    
    init(language: ToolLanguageModel, selectedLanguageId: String?) {
        
        super.init()
        
        self.name = language.name
        self.isSelected = language.id == selectedLanguageId
    }
}
