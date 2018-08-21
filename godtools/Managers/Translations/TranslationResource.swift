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
            guard let rID = translation["relationships"]["resource"]["data"]["id"].string, rID == resourceID else { continue }
            
            let translationResource = TranslationResource();
            
            if let id = translation["id"].string {
                translationResource.id = id
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
}
