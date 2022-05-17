//
//  LanguagesListItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class LanguagesListItemViewModel: BaseLanguagesListItemViewModel {
    
    private let language: LanguageModel
    
    required init(language: LanguageModel) {
        
        self.language = language
        
        super.init()
    }
}
