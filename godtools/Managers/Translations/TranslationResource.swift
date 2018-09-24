//
//  TranslationResource.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

class TranslationResource: GodToolsJSONResource {
    
    var id = ""
    var version = NSNumber(integerLiteral: 0)
    var isPublished = NSNumber(integerLiteral: 0)
    var manifestName = ""
    var translatedName = ""
    var translatedDescription = ""
    var tagline = ""
    var languageId = ""
}

// Mark - JSONResource protocol functions

extension TranslationResource {
    override func type() -> String {
        return "translation"
    }
    
    func attributeMappings() -> [String: String] {
        return ["isPublished": "is-published",
                "manifestName": "manifest-name",
                "translatedName": "translated-name",
                "translatedDescription": "translated-description",
                "tagline": "translated-tagline"]
    }
    
    func relatedObjectIdMappings() -> [String : String] {
        return ["languageId": "language"]
    }
}
