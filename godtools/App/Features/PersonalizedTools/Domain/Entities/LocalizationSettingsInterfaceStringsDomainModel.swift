//
//  LocalizationSettingsInterfaceStringsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/25/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct LocalizationSettingsInterfaceStringsDomainModel {
    
    let navTitle: String
    let localizationHeaderTitle: String
    let localizationHeaderDescription: String
    
    static var emptyValue: LocalizationSettingsInterfaceStringsDomainModel {
        return LocalizationSettingsInterfaceStringsDomainModel(navTitle: "", localizationHeaderTitle: "", localizationHeaderDescription: "")
    }
}
