//
//  RealmUserLocalizationSettings.swift
//  godtools
//
//  Created by Rachael Skeath on 1/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmUserLocalizationSettings: Object, IdentifiableRealmObject {

    @Persisted var id: String = ""
    @Persisted var createdAt: Date = Date()
    @Persisted var selectedCountryIsoRegionCode: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension RealmUserLocalizationSettings {
    
    func mapFrom(model: UserLocalizationSettingsDataModel) {
        id = model.id
        createdAt = model.createdAt
        selectedCountryIsoRegionCode = model.selectedCountryIsoRegionCode
    }
    
    static func createNewFrom(model: UserLocalizationSettingsDataModel) -> RealmUserLocalizationSettings {
        let object = RealmUserLocalizationSettings()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> UserLocalizationSettingsDataModel {
        UserLocalizationSettingsDataModel(
            id: id,
            createdAt: createdAt,
            selectedCountryIsoRegionCode: selectedCountryIsoRegionCode
        )
    }
}
