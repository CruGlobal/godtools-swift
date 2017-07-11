//
//  LanguageResource.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import Spine

class LanguageResource: Resource {

    var code: String?
    
    override class var resourceType: ResourceType {
        return "language"
    }
    
    override class var fields: [Field] {
        return fieldsFromDictionary([
            "code" : Attribute(),
            ])
    }
}
