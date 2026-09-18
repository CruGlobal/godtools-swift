//
//  SwiftUserToolFilterSettings.swift
//  godtools
//
//  Created by Rachael Skeath on 9/17/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftUserToolFilterSettings = SwiftUserToolFilterSettingsV1.SwiftUserToolFilterSettings

@available(iOS 17.4, *)
enum SwiftUserToolFilterSettingsV1 {
    
    @Model
    class SwiftUserToolFilterSettings: IdentifiableSwiftDataObject {
        
        var createdAt: Date = Date()
        var settingType: String = ""
        var userId: String = ""
        var value: String = ""
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftUserToolFilterSettings {
    
    public static func idPredicate(id: String) -> Predicate<SwiftUserToolFilterSettings> {
        return #Predicate<SwiftUserToolFilterSettings> { object in
            object.id == id
        }
    }
    
    public static func idsPredicate(ids: Set<String>) -> Predicate<SwiftUserToolFilterSettings> {
        return #Predicate<SwiftUserToolFilterSettings> { object in
            ids.contains(object.id)
        }
    }
    
    func mapFrom(model: UserToolFilterSettingsDataModel) {
        
        id = model.id
        createdAt = model.createdAt
        settingType = model.settingType
        userId = model.userId
        value = model.value
    }
    
    static func createNewFrom(model: UserToolFilterSettingsDataModel) -> SwiftUserToolFilterSettings {
        
        let object = SwiftUserToolFilterSettings()
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
