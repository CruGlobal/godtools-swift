//
//  SwiftTranslation.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftTranslation = SwiftTranslationV1.SwiftTranslation

@available(iOS 17.4, *)
enum SwiftTranslationV1 {
 
    @Model
    class SwiftTranslation: IdentifiableSwiftDataObject {
        
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
    }
}

@available(iOS 17.4, *)
extension SwiftTranslation {
    
    func mapFrom(model: TranslationDataModel) {
        id = model.id
        isPublished = model.isPublished
        manifestName = model.manifestName
        toolDetailsBibleReferences = model.toolDetailsBibleReferences
        toolDetailsConversationStarters = model.toolDetailsConversationStarters
        toolDetailsOutline = model.toolDetailsOutline
        translatedDescription = model.translatedDescription
        translatedName = model.translatedName
        translatedTagline = model.translatedTagline
        type = model.type
        version = model.version
    }
    
    static func createNewFrom(model: TranslationDataModel) -> SwiftTranslation {
        let translation = SwiftTranslation()
        translation.mapFrom(model: model)
        return translation
    }
    
    func toModel() -> TranslationDataModel {
        return TranslationDataModel(
            id: id,
            isPublished: isPublished,
            languageDataModel: languageDataModel,
            manifestName: manifestName,
            resourceDataModel: resourceDataModel,
            toolDetailsBibleReferences: toolDetailsBibleReferences,
            toolDetailsConversationStarters: toolDetailsConversationStarters,
            toolDetailsOutline: toolDetailsOutline,
            translatedDescription: translatedDescription,
            translatedName: translatedName,
            translatedTagline: translatedTagline,
            type: type,
            version: version
        )
    }
    
    var resourceDataModel: ResourceDataModel? {
        
        guard let swiftResource = resource else {
            return nil
        }
        
        return swiftResource.toModel()
    }
    
    var languageDataModel: LanguageDataModel? {
        
        guard let swiftLanguage = language else {
            return nil
        }
        
        return swiftLanguage.toModel()
    }
}

@available(iOS 17.4, *)
extension Array where Element == SwiftTranslation {
    
    func filterByLanguageId(languageId: String) -> [SwiftTranslation] {
        return filter {
            $0.language?.id == languageId
        }
    }
    
    func filterByLanguageCode(languageCode: BCP47LanguageIdentifier) -> [SwiftTranslation] {
        return filter {
            $0.language?.code == languageCode
        }
    }
    
    func sortByLatestVersionFirst() -> [SwiftTranslation] {
        sorted(by: {
            $0.version > $1.version
        })
    }
}
