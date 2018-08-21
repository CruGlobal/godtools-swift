//
//  TranslationResource.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SwiftyJSON

class TranslationResource {
    
    var id = ""
    var version = NSNumber(integerLiteral: 0)
    var isPublished = NSNumber(integerLiteral: 0)
    var manifestName = ""
    var translatedName = ""
    var translatedDescription = ""
    var tagline = ""
    
    var language: LanguageResource?
    
    static func initializeFrom(json: JSON, resourceID: String) -> [TranslationResource] {
        var translations = [TranslationResource]();
        for translation in json.arrayValue {
            guard let type = translation["type"].string, type == "translation" else { continue }
            guard let rID = translation["relationships"]["resource"]["data"]["id"].string, rID == resourceID else { continue }
            
            let translationResource = TranslationResource();
            
            if let id = translation["id"].string {
                translationResource.id = id
            }
            if let version = translation["attributes"]["version"].number {
                translationResource.version = version
            }
            if let isPublished = translation["attributes"]["is-published"].number {
                translationResource.isPublished = isPublished
            }
            if let manifestName = translation["attributes"]["manifest-name"].string {
                translationResource.manifestName = manifestName
            }
            if let translatedName = translation["attributes"]["translated-name"].string {
                translationResource.translatedName = translatedName
            }
            if let translatedDescription = translation["attributes"]["translated-description"].string {
                translationResource.translatedDescription = translatedDescription
            }
            if let tagline = translation["attributes"]["translated-tagline"].string {
                translationResource.tagline = tagline
            }
            if let languageId = translation["relationships"]["language"]["data"]["id"].string {
                translationResource.language = LanguageResource()
                translationResource.language?.id = languageId
            }
            
            translations.append(translationResource);
        }
        return translations;
    }
}
