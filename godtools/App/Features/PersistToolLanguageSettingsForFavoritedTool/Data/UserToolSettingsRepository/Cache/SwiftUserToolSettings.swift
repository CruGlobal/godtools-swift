//
//  SwiftUserToolSettings.swift
//  godtools
//
//  Created by Rachael Skeath on 10/9/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftUserToolSettings = SwiftUserToolSettingsV1.SwiftUserToolSettings

@available(iOS 17.4, *)
enum SwiftUserToolSettingsV1 {
    
    @Model
    class SwiftUserToolSettings: IdentifiableSwiftDataObject {
        
        var createdAt: Date = Date()
        var primaryLanguageId: String = ""
        var parallelLanguageId: String?
        
        @Attribute(.unique) var id: String = ""
        @Attribute(.unique) var toolId: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftUserToolSettings {
    
    func mapFrom(model: UserToolSettingsDataModel) {
        
        id = model.id
        createdAt = model.createdAt
        toolId = model.toolId
        primaryLanguageId = model.primaryLanguageId
        parallelLanguageId = model.parallelLanguageId
    }
    
    static func createNewFrom(model: UserToolSettingsDataModel) -> SwiftUserToolSettings {
        
        let object = SwiftUserToolSettings()
        object.mapFrom(model: model)
        return object
    }
}

@available(iOS 17.4, *)
extension SwiftUserToolSettings {
 
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
