//
//  LocalizationSettingsCountryDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 2/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct LocalizationSettingsCountryDomainModel: Sendable {

    let isoRegionCode: String
    let countryNameTranslatedInOwnLanguage: String
    let countryNameTranslatedInCurrentAppLanguage: String

    init(isoRegionCode: String, countryNameTranslatedInOwnLanguage: String = "", countryNameTranslatedInCurrentAppLanguage: String = "") {
        self.isoRegionCode = isoRegionCode
        self.countryNameTranslatedInOwnLanguage = countryNameTranslatedInOwnLanguage
        self.countryNameTranslatedInCurrentAppLanguage = countryNameTranslatedInCurrentAppLanguage
    }
}
