//
//  TranslationResource.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SwiftyJSON

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
        return ["is-published":"isPublished",
                "manifest-name":"manifestName",
                "translated-name":"translatedName",
                "translated-description":"translatedDescription",
                "translated-tagline":"tagline"]
    }
    
    func relatedAttributeMapping() -> [String : String] {
        return ["language": "languageId"]
    }
}
