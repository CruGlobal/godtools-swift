//
//  ResourceViews.swift
//  godtools
//
//  Created by Ryan Carlson on 6/1/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

class ResourceViews {
    
    var resourceId: NSNumber?
    var quantity: NSNumber?
    
    convenience init(resourceId: NSNumber, quantity: NSNumber) {
        self.init()
        self.resourceId = resourceId
        self.quantity = quantity
    }
}
