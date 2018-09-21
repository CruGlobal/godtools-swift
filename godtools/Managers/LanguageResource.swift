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
    override class var type: String {
        return "language"
    }
    
    override class var attributeMappings: [String : String] {
        return ["direction": "direction",
                "code": "code"]
    }
    
    var id = ""
    var code = ""
    var direction = ""
    

}
