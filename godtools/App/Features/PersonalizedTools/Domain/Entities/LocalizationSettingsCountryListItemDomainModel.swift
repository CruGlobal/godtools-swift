//
//  LocalizationSettingsCountryListItemDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct LocalizationSettingsCountryListItemDomainModel {

    let isoRegionCode: String
    let countryNameTranslatedInOwnLanguage: String
    let countryNameTranslatedInCurrentAppLanguage: String
}

extension LocalizationSettingsCountryListItemDomainModel: StringSearchable {

    var searchableStrings: [String] {
        return [
            countryNameTranslatedInOwnLanguage,
            countryNameTranslatedInCurrentAppLanguage
        ]
    }
}

extension LocalizationSettingsCountryListItemDomainModel: Identifiable {
    var id: String {
        return isoRegionCode
    }
}
