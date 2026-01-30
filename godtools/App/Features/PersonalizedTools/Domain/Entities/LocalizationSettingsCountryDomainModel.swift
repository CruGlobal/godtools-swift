//
//  LocalizationSettingsCountryDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct LocalizationSettingsCountryDomainModel {

    let isoRegionCode: String
    let countryNameTranslatedInOwnLanguage: String
    let countryNameTranslatedInCurrentAppLanguage: String
}

extension LocalizationSettingsCountryDomainModel: StringSearchable {

    var searchableStrings: [String] {
        return [
            countryNameTranslatedInOwnLanguage,
            countryNameTranslatedInCurrentAppLanguage
        ]
    }
}

extension LocalizationSettingsCountryDomainModel: Identifiable {
    var id: String {
        return isoRegionCode
    }
}
