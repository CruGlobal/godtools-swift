//
//  ToolDetailsVersionsCardViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ToolDetailsVersionsCardViewModel: ObservableObject {
    
    let name: String
    let description: String
    let languages: String
    
    init(toolVersion: ToolVersion) {
        
        name = toolVersion.name
        description = toolVersion.description
        languages = toolVersion.languages
    }
}
