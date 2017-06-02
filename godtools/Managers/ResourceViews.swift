//
//  ResourceViews.swift
//  godtools
//
//  Created by Ryan Carlson on 6/1/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import Spine

class ResourceViews: Resource {
    
    var resourceId: NSNumber?
    var quantity: NSNumber?
    
    convenience init(resourceId: NSNumber, quantity: NSNumber) {
        self.init()
        self.resourceId = resourceId
        self.quantity = quantity
    }
    
    override class var resourceType: ResourceType {
        return "view"
    }
    
    override class var fields: [Field] {
        return fieldsFromDictionary([
            "resourceId" : Attribute().serializeAs("resource_id"),
            "quantity" : Attribute()])
    }
}
