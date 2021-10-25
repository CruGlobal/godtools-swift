//
//  MobileContentButtonIcon.swift
//  godtools
//
//  Created by Robert Eldredge on 10/25/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

enum IconGravity {
    case start
    case end
}

struct MobileContentButtonIcon {
    
    var name: String
    var size: Int32
    var gravity: IconGravity
}

