//
//  AttachmentResource.swift
//  godtools
//
//  Created by Ryan Carlson on 5/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SwiftyJSON

class AttachmentResource: NSObject {

    var id = ""
    var sha256 = ""
    
    required override init() {
        super.init()
    }
}

extension AttachmentResource: JSONResource {

    func type() -> String {
        return "attachment"
    }
 
    override func setValue(_ value: Any?, forKey key: String) {
        super.setValue(value, forKey: key)
    }
}
