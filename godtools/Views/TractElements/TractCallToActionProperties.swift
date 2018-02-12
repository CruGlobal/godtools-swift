//
//  TractCallToActionProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractCallToActionProperties: TractProperties {
    
    var events: String?
    var controlColor: UIColor?
    
    override func defineProperties() {
        self.properties = ["events"]
    }
    
    override func customProperties() -> [String]? {
        return ["controlColor"]
    }
    
    override func getTextProperties() -> TractTextContentProperties {
        let textProperties = TractTextContentProperties()
        
        textProperties.xMargin = TractCallToAction.paddingConstant
        textProperties.yMargin = TractCallToAction.paddingConstant
        textProperties.textColor = self.textColor
        
        return textProperties
    }

    override func performCustomProperty(propertyName: String, value: String) {
        if propertyName == "controlColor" {
            controlColor = value.getRGBAColor()
        }
    }
}
