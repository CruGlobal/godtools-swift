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
    
    var version: Int?
    var isPublished: Bool?
    
    override class var resourceType: ResourceType {
        return "translation"
    }
    
    override class var fields: [Field] {
        return fieldsFromDictionary([
            "version" : Attribute(),
            "isPublished" : Attribute().serializeAs("is-published")
        ])
    }
}
