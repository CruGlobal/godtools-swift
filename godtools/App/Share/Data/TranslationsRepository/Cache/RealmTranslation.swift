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

class RealmTranslation: Object, IdentifiableRealmObject, TranslationDataModelInterface {
    
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
}

extension RealmTranslation {
    
    func mapFrom(interface: TranslationDataModelInterface) {
        
        id = interface.id
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
    
    static func createNewFrom(interface: TranslationDataModelInterface) -> RealmTranslation {
        
        let realmTranslation = RealmTranslation()
        realmTranslation.mapFrom(interface: interface)
        return realmTranslation
    }
    
    var resourceDataModel: ResourceDataModel? {
        
        guard let resource = resource else {
            return nil
        }
        
        return ResourceDataModel(interface: resource)
    }
    
    var languageDataModel: LanguageDataModel? {
        
        guard let language = language else {
            return nil
        }
        
        return LanguageDataModel(interface: language)
    }
}
