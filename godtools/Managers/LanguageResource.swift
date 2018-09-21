//
//  LanguageResource.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SwiftyJSON

class LanguageResource: JSONResource {
    
    var id = ""
    var code = ""
    var direction = ""
    
    override func attributeMappings() -> [String : String] {
        return ["direction": "direction",
                "code": "code"]
    }
}
