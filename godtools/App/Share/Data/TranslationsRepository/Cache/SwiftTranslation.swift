//
//  SwiftTranslation.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17.4, *)
typealias SwiftTranslation = SwiftTranslationV1.SwiftTranslation

@available(iOS 17.4, *)
enum SwiftTranslationV1 {
 
    @Model
    class SwiftTranslation: IdentifiableSwiftDataObject, TranslationDataModelInterface {
        
        var isPublished: Bool = false
        var manifestName: String = ""
        var toolDetailsBibleReferences: String = ""
        var toolDetailsConversationStarters: String = ""
        var toolDetailsOutline: String = ""
        var translatedDescription: String = ""
        var translatedName: String = ""
        var translatedTagline: String = ""
        var type: String = ""
        var version: Int = -1
        
        @Attribute(.unique) var id: String = ""
        
        @Relationship(deleteRule: .nullify) var resource: SwiftResource?
        @Relationship(deleteRule: .nullify) var language: SwiftLanguage?
        
        init() {
            
        }
        
        func mapFrom(interface: TranslationDataModelInterface) {
            isPublished = interface.isPublished
            manifestName = interface.manifestName
            toolDetailsBibleReferences = interface.toolDetailsBibleReferences
            toolDetailsConversationStarters = interface.toolDetailsConversationStarters
            toolDetailsOutline = interface.toolDetailsOutline
            translatedDescription = interface.translatedDescription
            translatedName = interface.translatedName
            translatedTagline = interface.translatedTagline
            type = interface.type
            version = interface.version
        }
        
        static func createNewFrom(interface: TranslationDataModelInterface) -> SwiftTranslation {
            let translation = SwiftTranslation()
            translation.mapFrom(interface: interface)
            return translation
        }
        
        var resourceDataModel: ResourceDataModel? {
            
            guard let swiftResource = resource else {
                return nil
            }
            
            return ResourceDataModel(interface: swiftResource)
        }
        
        var languageDataModel: LanguageDataModel? {
            
            guard let swiftLanguage = language else {
                return nil
            }
            
            return LanguageDataModel(interface: swiftLanguage)
        }
    }
}
