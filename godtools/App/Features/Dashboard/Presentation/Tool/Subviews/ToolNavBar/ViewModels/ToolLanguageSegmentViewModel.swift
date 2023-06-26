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
    
    required init(language: LanguageDomainModel) {
        
        self.title = language.translatedName
    }
}
