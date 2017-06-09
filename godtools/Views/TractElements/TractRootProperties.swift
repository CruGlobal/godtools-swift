//
//  TractRootProperties.swift
//  godtools
//
//  Created by Devserker on 5/29/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractRootProperties: XMLNode {
    
    var primaryColor: UIColor?
    var primaryTextColor: UIColor?
    var textColor: UIColor?
    var backgroundProperties = TractBackgroundProperties()
    
    override func loadCustomProperties(_ properties: [String: Any]) {
        self.backgroundProperties.load(properties)
    }

}
