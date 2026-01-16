//
//  RealmUserLocalizationSetting.swift
//  godtools
//
//  Created by Rachael Skeath on 1/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmUserLocalizationSetting: Object {

    static let primaryKeyValue: String = "user"

    @Persisted var id: String = RealmUserLocalizationSetting.primaryKeyValue
    @Persisted var createdAt: Date = Date()
    @Persisted var selectedCountryIsoRegionCode: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    func mapFrom(dataModel: UserLocalizationSettingDataModel) {
        id = dataModel.id
        createdAt = dataModel.createdAt
        selectedCountryIsoRegionCode = dataModel.selectedCountryIsoRegionCode
    }
}
