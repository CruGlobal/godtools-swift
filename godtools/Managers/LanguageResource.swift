//
//  LanguageResource.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SwiftyJSON

class LanguageResource: GodToolsJSONResource {
    
    var id = ""
    var code = ""
    var direction = ""
}

// Mark - JSONResource protocol functions

extension LanguageResource {

    override func type() -> String {
        return "language"
    }
}
