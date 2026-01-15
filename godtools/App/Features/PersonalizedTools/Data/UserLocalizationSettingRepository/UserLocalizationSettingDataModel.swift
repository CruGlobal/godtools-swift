//
//  UserLocalizationSettingDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 1/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct UserLocalizationSettingDataModel {

    let id: String
    let createdAt: Date
    let selectedCountryName: String

    init(selectedCountryName: String) {
        self.id = RealmUserLocalizationSetting.primaryKeyValue
        self.createdAt = Date()
        self.selectedCountryName = selectedCountryName
    }

    init(realmObject: RealmUserLocalizationSetting) {
        self.id = realmObject.id
        self.createdAt = realmObject.createdAt
        self.selectedCountryName = realmObject.selectedCountryName
    }
}
