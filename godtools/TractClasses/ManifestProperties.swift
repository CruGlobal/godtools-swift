//
//  ManifestProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/9/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class ManifestProperties: XMLNode {
    
    var textSize = "18px"
    var styleProperties = TractStyleProperties()
    
    override func loadCustomProperties(_ properties: [String: Any]) {
        self.styleProperties.load(properties)
    }
    
}
