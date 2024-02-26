//
//  ToolSettingsLanguages.swift
//  godtools
//
//  Created by Levi Eggert on 2/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class ToolSettingsLanguages {
    
    let primaryLanguageId: String
    let parallelLanguageId: String?
    let selectedLanguageId: String
    
    init(primaryLanguageId: String, parallelLanguageId: String?, selectedLanguageId: String) {
        
        self.primaryLanguageId = primaryLanguageId
        self.parallelLanguageId = parallelLanguageId
        self.selectedLanguageId = selectedLanguageId
    }
}
