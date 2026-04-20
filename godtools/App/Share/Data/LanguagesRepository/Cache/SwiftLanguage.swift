//
//  SwiftLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftLanguage = SwiftLanguageV1.SwiftLanguage

@available(iOS 17.4, *)
enum SwiftLanguageV1 {
 
    @Model
    class SwiftLanguage: IdentifiableSwiftDataObject {
        
        var code: BCP47LanguageIdentifier = ""
        var directionString: String = ""
        var name: String = ""
        var type: String = ""
        var forceLanguageName: Bool = false
        
        @Attribute(.unique) var id: String = ""
        
        @Relationship(deleteRule: .noAction, inverse: \SwiftResource.languages) var resources: [SwiftResource] = Array<SwiftResource>()
                        
        init() {
            
        }
        
        func mapFrom(model: LanguageDataModel) {
            code = model.code
            directionString = model.directionString
            id = model.id
            name = model.name
            type = model.type
            forceLanguageName = model.forceLanguageName
        }
        
        static func createNewFrom(model: LanguageDataModel) -> SwiftLanguage {
            let swiftLanguage = SwiftLanguage()
            swiftLanguage.mapFrom(model: model)
            return swiftLanguage
        }
    }
}

@available(iOS 17.4, *)
extension SwiftLanguage {
    
    func toModel() -> LanguageDataModel {
        return LanguageDataModel(
            code: code,
            directionString: directionString,
            id: id,
            name: name,
            type: type,
            forceLanguageName: forceLanguageName
        )
    }
}
