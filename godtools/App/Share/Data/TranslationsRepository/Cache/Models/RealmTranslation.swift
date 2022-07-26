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
    @objc dynamic var languageId: String?
    @objc dynamic var manifestName: String = ""
    @objc dynamic var resourceId: String?
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
    
    func mapFrom(model: TranslationModel) {
        
        id = model.id
        isPublished = model.isPublished
        languageId = model.languageId
        manifestName = model.manifestName
        resourceId = model.resourceId
        translatedDescription = model.translatedDescription
        translatedName = model.translatedName
        translatedTagline = model.translatedTagline
        type = model.type
        version = model.version
    }
}
