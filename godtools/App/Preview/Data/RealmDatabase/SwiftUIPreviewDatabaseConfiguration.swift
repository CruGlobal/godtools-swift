//
//  SwiftUIPreviewDatabaseConfiguration.swift
//  godtools
//
//  Created by Levi Eggert on 8/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class SwiftUIPreviewDatabaseConfiguration: RealmDatabaseConfiguration {
    
    init() {
        
        super.init(
            cacheType: .inMemory(identifier: "godtools_swiftui_preview_database"),
            schemaVersion: 1
        )
    }
}
