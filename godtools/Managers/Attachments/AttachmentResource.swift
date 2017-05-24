//
//  AttachmentResource.swift
//  godtools
//
//  Created by Ryan Carlson on 5/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import Spine

class AttachmentResource: Resource {

    var sha256: String?
    
    override class var resourceType: ResourceType {
        return "attachment"
    }
    
    override class var fields: [Field] {
        return fieldsFromDictionary([
            "sha256" : Attribute(),
        ])
    }
}
