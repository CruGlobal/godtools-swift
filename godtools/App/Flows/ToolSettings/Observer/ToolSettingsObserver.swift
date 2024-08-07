//
//  ToolSettingsObserver.swift
//  godtools
//
//  Created by Levi Eggert on 2/22/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class ToolSettingsObserver: ObservableObject {
    
    @Published var languages: ToolSettingsLanguages
    @Published var trainingTipsEnabled: Bool
    
    let toolId: String
    let pageNumber: Int
    
    init(toolId: String, languages: ToolSettingsLanguages, pageNumber: Int, trainingTipsEnabled: Bool) {
        
        self.toolId = toolId
        self.languages = languages
        self.pageNumber = pageNumber
        self.trainingTipsEnabled = trainingTipsEnabled
    }
}
