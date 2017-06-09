//
//  TractPageProperties.swift
//  godtools
//
//  Created by Devserker on 5/29/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractPageProperties: TractProperties {
    
    // MARK: - XML Properties
    
    var styleProperties = TractStyleProperties()
    
    // MARK: - Setup of custom properties
    
    override func loadCustomProperties(_ properties: [String: Any]) {
        self.styleProperties.load(properties)
    }

}
