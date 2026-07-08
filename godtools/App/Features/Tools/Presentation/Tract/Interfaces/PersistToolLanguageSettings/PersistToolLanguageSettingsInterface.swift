//
//  PersistToolLanguageSettingsInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 4/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

protocol PersistToolLanguageSettingsInterface {
    
    func persistSettings(toolId: String, primaryLanguageId: String, parallelLanguageId: String?) async throws -> Bool
}
