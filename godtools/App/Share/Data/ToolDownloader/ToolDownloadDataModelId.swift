//
//  ToolDownloadDataModelId.swift
//  godtools
//
//  Created by Levi Eggert on 6/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct ToolDownloadDataModelId: Sendable {
    
    let value: String
    
    init(toolId: String, languages: [BCP47LanguageIdentifier]) {
        
        value = toolId + "_" + languages.joined(separator: "_")
    }
}
