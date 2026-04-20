//
//  RealmTranslation.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmTranslation: Object, IdentifiableRealmObject {
    
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
    
    static func createNewFrom(model: TranslationDataModel) -> RealmTranslation {
        
        let realmTranslation = RealmTranslation()
        realmTranslation.mapFrom(model: model)
        return realmTranslation
    }
}

extension RealmTranslation {
    
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
}

extension RealmTranslation {
    
    var resourceDataModel: ResourceDataModel? {
        
        guard let resource = resource else {
            return nil
        }
        
        return resource.toModel()
    }
    
    var languageDataModel: LanguageDataModel? {
        
        guard let language = language else {
            return nil
        }
        
        return language.toModel()
    }
}
