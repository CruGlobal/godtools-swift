//
//  SwiftLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17.4, *)
typealias SwiftLanguage = SwiftLanguageV1.SwiftLanguage

@available(iOS 17.4, *)
enum SwiftLanguageV1 {
 
    @Model
    class SwiftLanguage: IdentifiableSwiftDataObject, LanguageDataModelInterface {
        
        var code: BCP47LanguageIdentifier = ""
        var directionString: String = ""
        @Attribute(.unique) var id: String = ""
        var name: String = ""
        var type: String = ""
        var forceLanguageName: Bool = false
        
        @Relationship(deleteRule: .noAction, inverse: \SwiftResource.languages) var resources: [SwiftResource] = Array<SwiftResource>()
                        
        init() {
            
        }
        
        func mapFrom(interface: LanguageDataModelInterface) {
            code = interface.code
            directionString = interface.directionString
            id = interface.id
            name = interface.name
            type = interface.type
            forceLanguageName = interface.forceLanguageName
        }
        
        static func createNewFrom(interface: LanguageDataModelInterface) -> SwiftLanguage {
            let swiftLanguage = SwiftLanguage()
            swiftLanguage.mapFrom(interface: interface)
            return swiftLanguage
        }
    }
}
