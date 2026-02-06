//
//  UserLocalizationSettingsDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 1/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct UserLocalizationSettingsDataModel: UserLocalizationSettingsDataModelInterface {

    let id: String
    let createdAt: Date
    let selectedCountryIsoRegionCode: String

    init(id: String, selectedCountryIsoRegionCode: String) {
        self.id = id
        self.createdAt = Date()
        self.selectedCountryIsoRegionCode = selectedCountryIsoRegionCode
    }

    init(interface: UserLocalizationSettingsDataModelInterface) {
        self.id = interface.id
        self.createdAt = interface.createdAt
        self.selectedCountryIsoRegionCode = interface.selectedCountryIsoRegionCode
    }
}
