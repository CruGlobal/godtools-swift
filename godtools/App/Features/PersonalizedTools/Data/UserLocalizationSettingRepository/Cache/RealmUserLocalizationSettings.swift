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

class RealmUserLocalizationSettings: Object, IdentifiableRealmObject, UserLocalizationSettingsDataModelInterface {

    @Persisted var id: String = ""
    @Persisted var createdAt: Date = Date()
    @Persisted var selectedCountryIsoRegionCode: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    func mapFrom(interface: UserLocalizationSettingsDataModelInterface) {
        id = interface.id
        createdAt = interface.createdAt
        selectedCountryIsoRegionCode = interface.selectedCountryIsoRegionCode
    }
    
    static func createNewFrom(interface: UserLocalizationSettingsDataModelInterface) -> RealmUserLocalizationSettings {
        let object = RealmUserLocalizationSettings()
        object.mapFrom(interface: interface)
        return object
    }
}
