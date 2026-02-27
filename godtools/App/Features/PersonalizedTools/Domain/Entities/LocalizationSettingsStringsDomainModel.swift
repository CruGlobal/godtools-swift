//
//  LocalizationSettingsStringsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/25/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct LocalizationSettingsStringsDomainModel {

    let navTitle: String
    let localizationHeaderTitle: String
    let localizationHeaderDescription: String

    static var emptyValue: LocalizationSettingsStringsDomainModel {
        return LocalizationSettingsStringsDomainModel(
            navTitle: "",
            localizationHeaderTitle: "",
            localizationHeaderDescription: ""
        )
    }
}
