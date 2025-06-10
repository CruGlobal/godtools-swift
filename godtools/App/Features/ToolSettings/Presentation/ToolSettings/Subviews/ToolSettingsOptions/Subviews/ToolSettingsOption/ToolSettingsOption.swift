//
//  ToolSettingsOption.swift
//  godtools
//
//  Created by Levi Eggert on 6/4/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

enum ToolSettingsOption: String {
    
    case shareLink
    case shareScreen
    case trainingTips
}

extension ToolSettingsOption: Identifiable {
    var id: String {
        return rawValue
    }
}
