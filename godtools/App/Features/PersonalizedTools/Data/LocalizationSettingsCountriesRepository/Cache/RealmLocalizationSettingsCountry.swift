//
//  RealmLocalizationSettingsCountry.swift
//  godtools
//
//  Created by Rachael Skeath on 12/8/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmLocalizationSettingsCountry: Object {
    
    // TODO: - add correct properties
    
    @Persisted var id: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}
