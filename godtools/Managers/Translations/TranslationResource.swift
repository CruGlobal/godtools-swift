//
//  TranslationResource.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import Spine

class TranslationResource: Resource {
    
    var version: NSNumber?
    var isPublished: NSNumber?
    var manifestName: String?
    var translatedName: String?
    var translatedDescription: String?
    
    var language: LanguageResource?
    
    override class var resourceType: ResourceType {
        return "translation"
    }
    
    override class var fields: [Field] {
        return fieldsFromDictionary([
            "version" : Attribute(),
            "isPublished" : BooleanAttribute().serializeAs("is-published"),
            "manifestName" : Attribute().serializeAs("manifest-name"),
            "translatedName": Attribute().serializeAs("translated-name"),
            "translatedDescription": Attribute().serializeAs("translated-description"),
            "language" : ToOneRelationship(LanguageResource.self)
        ])
    }
}
