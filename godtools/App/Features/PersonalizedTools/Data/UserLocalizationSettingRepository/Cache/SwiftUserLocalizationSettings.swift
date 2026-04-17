//
//  SwiftUserLocalizationSettings.swift
//  godtools
//
//  Created by Levi Eggert on 2/5/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftUserLocalizationSettings = SwiftUserLocalizationSettingsV1.SwiftUserLocalizationSettings

@available(iOS 17.4, *)
enum SwiftUserLocalizationSettingsV1 {
 
    @Model
    class SwiftUserLocalizationSettings: IdentifiableSwiftDataObject {
        
        var createdAt: Date = Date()
        var selectedCountryIsoRegionCode: String = ""
        
        @Attribute(.unique) var id: String = ""
                                
        init() {
            
        }
        
        func mapFrom(model: UserLocalizationSettingsDataModel) {
            createdAt = model.createdAt
            selectedCountryIsoRegionCode = model.selectedCountryIsoRegionCode
            id = model.id
        }
        
        static func createNewFrom(model: UserLocalizationSettingsDataModel) -> SwiftUserLocalizationSettings {
            let object = SwiftUserLocalizationSettings()
            object.mapFrom(model: model)
            return object
        }
    }
}

@available(iOS 17.4, *)
extension SwiftUserLocalizationSettings {
    
    func toModel() -> UserLocalizationSettingsDataModel {
        UserLocalizationSettingsDataModel(
            id: id,
            createdAt: createdAt,
            selectedCountryIsoRegionCode: selectedCountryIsoRegionCode
        )
    }
}
