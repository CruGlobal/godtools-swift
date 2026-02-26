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
    class SwiftUserLocalizationSettings: IdentifiableSwiftDataObject, UserLocalizationSettingsDataModelInterface {
        
        var createdAt: Date = Date()
        var selectedCountryIsoRegionCode: String = ""
        
        @Attribute(.unique) var id: String = ""
                                
        init() {
            
        }
        
        func mapFrom(interface: UserLocalizationSettingsDataModelInterface) {
            createdAt = interface.createdAt
            selectedCountryIsoRegionCode = interface.selectedCountryIsoRegionCode
            id = interface.id
        }
        
        static func createNewFrom(interface: UserLocalizationSettingsDataModelInterface) -> SwiftUserLocalizationSettings {
            let object = SwiftUserLocalizationSettings()
            object.mapFrom(interface: interface)
            return object
        }
    }
}
