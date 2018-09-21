//
//  LanguageResource.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SwiftyJSON

class LanguageResource: NSObject {
    
    var id = ""
    var code = ""
    var direction = ""
    
    required override init() {
        super.init()
    }

}

extension LanguageResource: JSONResource {

    func type() -> String {
        return "language"
    }
    
    func attributeMappings() -> [String : String] {
        return ["direction": "direction",
                "code": "code"]
    }
    
    func includedObjectMappings() -> [String : JSONResource.Type] {
        return [String: JSONResource.Type]()
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        super.setValue(value, forKey: key)
    }
}
