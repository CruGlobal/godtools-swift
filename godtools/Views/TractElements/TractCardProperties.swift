//
//  TractCardProperties.swift
//  godtools
//
//  Created by Devserker on 5/16/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractCardProperties: TractElementProperties {
    
    var backgroundProperties = TractBackgroundProperties()
    
    override func load(_ properties: [String: Any]) {
        super.load(properties)
        self.backgroundProperties.load(properties)
    }
    
}
