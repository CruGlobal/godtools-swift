//
//  TranslationResource.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import Spine
import SwiftyJSON

class TranslationResource: Resource {
    
    var id2 = ""
    var version: NSNumber?
    var isPublished: NSNumber?
    var manifestName: String?
    var translatedName: String?
    var translatedDescription: String?
    var tagline: String?
    
    var language: LanguageResource?
    
    static func initializeFrom(data: Data) -> [TranslationResource] {
        var translations = [TranslationResource]();
        
        let json = JSON(data: data)["data"]
        
        for translation in json.arrayValue {
            let translationResource = TranslationResource();
            
            if let id2 = translation["id"].string {
                translationResource.id2 = id2
            }
            if let version = translation["version"].number {
                translationResource.version = version
            }
            if let isPublished = translation["isPublished"].number {
                translationResource.isPublished = isPublished
            }
            if let manifestName = translation["manifestName"].string {
                translationResource.manifestName = manifestName
            }
            if let translatedName = translation["translatedName"].string {
                translationResource.translatedName = translatedName
            }
            if let translatedDescription = translation["translatedDescription"].string {
                translationResource.translatedDescription = translatedDescription
            }
            if let tagline = translation["tagline"].string {
                translationResource.tagline = tagline
            }

            translations.append(translationResource);
        }
        
        return translations;
    }
    
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
            "language" : ToOneRelationship(LanguageResource.self),
            "tagline": Attribute().serializeAs("translated-tagline")
        ])
    }
}
