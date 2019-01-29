//
//  TranslationResource.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

class TranslationResource: GodToolsJSONResource {
    
    @objc var id = ""
    @objc var version = NSNumber(integerLiteral: 0)
    @objc var isPublished = NSNumber(integerLiteral: 0)
    @objc var manifestName = ""
    @objc var translatedName = ""
    @objc var translatedDescription = ""
    @objc var tagline = ""
    @objc var languageId = ""
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
