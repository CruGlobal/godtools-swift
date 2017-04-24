//
//  PageResource.swift
//  godtools
//
//  Created by Ryan Carlson on 4/21/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import Spine

class PageResource: Resource {
    
    var filename: String?
    
    override class var resourceType: ResourceType {
        return "page"
    }
    
    override class var fields: [Field] {
        return fieldsFromDictionary(["filename" : Attribute()])
    }
}
