//
//  RealmTranslation.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmTranslation: Object, TranslationModelType {
    
    @objc dynamic var id: String = ""
    @objc dynamic var isPublished: Bool = false
    @objc dynamic var manifestName: String = ""
    @objc dynamic var toolDetailsBibleReferences: String = ""
    @objc dynamic var toolDetailsConversationStarters: String = ""
    @objc dynamic var toolDetailsOutline: String = ""
    @objc dynamic var translatedDescription: String = ""
    @objc dynamic var translatedName: String = ""
    @objc dynamic var translatedTagline: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var version: Int = -1
    
    @objc dynamic var resource: RealmResource?
    @objc dynamic var language: RealmLanguage?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(model: TranslationModelType) {
        
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
    
    func getResource() -> ResourceModel? {
        
        guard let realmResource = resource else {
            return nil
        }
        
        return ResourceModel(model: realmResource)
    }
    
    func getLanguage() -> LanguageModel? {
        
        guard let realmLanguage = language else {
            return nil
        }
        
        return LanguageModel(model: realmLanguage)
    }
}
