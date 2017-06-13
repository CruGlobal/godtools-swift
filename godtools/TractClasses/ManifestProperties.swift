//
//  ManifestProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/9/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class ManifestProperties: XMLNode {
    
    var navBarColor = GTAppDefaultStyle.navBarColor.getRGBAColor()
    var navBarControlColor = GTAppDefaultStyle.navBarControlColor.getRGBAColor()
    var styleProperties = MainStyleProperties()
    
    override func loadCustomProperties(_ properties: [String: Any]) {
        self.styleProperties.load(properties)
    }
    
}
