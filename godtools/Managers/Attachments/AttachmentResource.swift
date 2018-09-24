//
//  AttachmentResource.swift
//  godtools
//
//  Created by Ryan Carlson on 5/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

class AttachmentResource: GodToolsJSONResource {

    var id = ""
    var sha256 = ""
}

// Mark - JSONResource protocol functions

extension AttachmentResource {

    override func type() -> String {
        return "attachment"
    }
}
