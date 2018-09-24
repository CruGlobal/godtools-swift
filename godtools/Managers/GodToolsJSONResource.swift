//
//  GodToolsJSONResource.swift
//  godtools
//
//  Created by Ryan Carlson on 9/24/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import Foundation

class GodToolsJSONResource: NSObject {
    required override init() {
        super.init()
    }
}

extension GodToolsJSONResource: JSONResource {
    func type() -> String {
        assertionFailure("this function must be overridden by a child class")
        return ""
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        super.setValue(value, forKey: key)
    }
}
