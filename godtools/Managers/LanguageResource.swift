//
//  LanguageResource.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation


/* E.g.
  "data": [
        {
            "id": "12",
            "type": "language",
            "attributes": {
                "code": "ar",
                "name": "Arabic",
                "direction": "rtl"
            },
            "relationships": {
                "translations": {
                    "data": [
                        {
                            "id": "113",
                            "type": "translation"
                        }
                    ]
                },
                "custom-pages": {
                    "data": []
                }
            }
        },
 ...
 */


struct LangResource: Decodable {
    var data: [LangResourceItem]?
}
struct LangResourceItem: Decodable {
    var id: String?
    var type: String?
    var attributes: LangResourceAttributes?
    var relationships: LangResourceRelationships?
}
struct LangResourceAttributes: Decodable {
    var code: String?
    var name: String?
    var direction: String?
}
struct LangResourceRelationships: Decodable {
    var translations: LangResourceTranslations?
}
struct LangResourceTranslations: Decodable {
    var data: [ [String: String] ]?
}


class LanguageResource: GodToolsJSONResource {
    
    @objc var id = ""
    @objc var code = ""
    @objc var direction = ""
    @objc var name: String?
}

// Mark - JSONResource protocol functions

extension LanguageResource {

    override func type() -> String {
        return "language"
    }
}
