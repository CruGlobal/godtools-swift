//
//  RealmUserToolSettings.swift
//  godtools
//
//  Created by Rachael Skeath on 5/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmUserToolSettings: Object, IdentifiableRealmObject {
    
    @objc dynamic var id: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var toolId: String = "" {
        didSet {
            id = toolId
        }
    }
    @objc dynamic var primaryLanguageId: String = ""
    @objc dynamic var parallelLanguageId: String?
    
    override static func primaryKey() -> String? {
        return "toolId"
    }
}

extension RealmUserToolSettings {
    
    func mapFrom(model: UserToolSettingsDataModel) {
        
        id = model.id
        createdAt = model.createdAt
        toolId = model.toolId
        primaryLanguageId = model.primaryLanguageId
        parallelLanguageId = model.parallelLanguageId
    }
    
    static func createNewFrom(model: UserToolSettingsDataModel) -> RealmUserToolSettings {
        
        let object = RealmUserToolSettings()
        object.mapFrom(model: model)
        return object
    }
 
    func toModel() -> UserToolSettingsDataModel {
        return UserToolSettingsDataModel(
            id: id,
            createdAt: createdAt,
            toolId: toolId,
            primaryLanguageId: primaryLanguageId,
            parallelLanguageId: parallelLanguageId
        )
    }
}
