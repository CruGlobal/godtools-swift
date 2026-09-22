//
//  RealmUserToolFilterSettings.swift
//  godtools
//
//  Created by Rachael Skeath on 9/17/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmUserToolFilterSettings: Object, IdentifiableRealmObject {
    
    @objc dynamic var id: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var settingType: String = ""
    @objc dynamic var userId: String = ""
    @objc dynamic var value: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension RealmUserToolFilterSettings {
    
    func mapFrom(model: UserToolFilterSettingsDataModel) {
        
        id = model.id
        createdAt = model.createdAt
        settingType = model.settingType
        userId = model.userId
        value = model.value
    }
    
    static func createNewFrom(model: UserToolFilterSettingsDataModel) -> RealmUserToolFilterSettings {
        
        let object = RealmUserToolFilterSettings()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> UserToolFilterSettingsDataModel {
        return UserToolFilterSettingsDataModel(
            id: id,
            createdAt: createdAt,
            settingType: settingType,
            userId: userId,
            value: value
        )
    }
}
