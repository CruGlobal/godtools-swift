//
//  TranslationResource.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SwiftyJSON

class TranslationResource: NSObject {
    
    var id = ""
    var version = NSNumber(integerLiteral: 0)
    var isPublished = NSNumber(integerLiteral: 0)
    var manifestName = ""
    var translatedName = ""
    var translatedDescription = ""
    var tagline = ""
    var languageId = ""
    
    required override init() {
        super.init()
    }
}

extension TranslationResource: JSONResource {
    func type() -> String {
        return "translation"
    }
    
    func attributeMappings() -> [String: String] {
        return ["version":"version",
                "is-published":"isPublished",
                "manifest-name":"manifestName",
                "translated-name":"translatedName",
                "translated-description":"translatedDescription",
                "translated-tagline":"tagline"]
    }
    
    func relatedAttributeMapping() -> [String : String] {
        return ["language": "languageId"]
    }
    
    func includedObjectMappings() -> [String: JSONResource.Type] {
        return [String: JSONResource.Type]()
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        super.setValue(value, forKey: key)
    }
}
