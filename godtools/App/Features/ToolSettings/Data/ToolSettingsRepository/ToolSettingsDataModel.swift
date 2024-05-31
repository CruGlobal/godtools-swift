//
//  ToolSettingsDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct ToolSettingsDataModel {
    
    let createdAt: Date = Date()
    let toolId: String
    let primaryLanguageId: String
    let parallelLanguageId: String?
}
