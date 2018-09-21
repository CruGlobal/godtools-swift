//
//  TranslationResource.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SwiftyJSON

class TranslationResource: JSONResource {
    
    override class var type: String {
        return "translation"
    }
    
    override class var attributeMappings: [String: String] {
        return ["name":"name",
                "version":"version",
                "is-published":"isPublished",
                "manifest-name":"manifestName",
                "translated-name":"translatedName",
                "translated-description":"translatedDescription",
                "translated-tagline":"tagline"]
    }
    
    override class var includedObjectMappings: [String: JSONResource.Type] {
        return ["language": LanguageResource.self]
    }
    
    var id = ""
    var version = NSNumber(integerLiteral: 0)
    var isPublished = NSNumber(integerLiteral: 0)
    var manifestName = ""
    var translatedName = ""
    var translatedDescription = ""
    var tagline = ""
    
    var language: LanguageResource?
}
