//
//  TractEventProperties.swift
//  godtools
//
//  Created by Greg Weiss on 5/7/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import UIKit

class TractEventProperties: TractProperties {
    
    // MARK: - XML Properties
    
    var system: String = ""
    var action: String = ""
    var key: String = ""
    var value: String = ""
    var analyticsDictionary: [String: String] = [:]
    
    var attribute: [String: String] {
        get {
            return [key: value]
        }
    }
    
    override func customProperties() -> [String]? {
        return ["event", "attribute", "analytics"]
    }
    
//    override func defineProperties() {
//       // self.properties = []
//    }
    
}
