//
//  ToolLanguageSegmentViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolLanguageSegmentViewModel {
    
    let title: String
    
    required init(language: LanguageModel, localizationServices: LocalizationServices) {
        
        title = LanguageViewModel(language: language, localizationServices: localizationServices).translatedLanguageName
    }
}
