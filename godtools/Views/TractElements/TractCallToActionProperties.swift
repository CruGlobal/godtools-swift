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
    
    override func properties() -> [String]? {
        return ["events"]
    }
    
    override func getTextProperties() -> TractTextContentProperties {
        let textProperties = TractTextContentProperties()
        
        textProperties.width = self.width - self.buttonSizeConstant - (self.buttonSizeXMargin * CGFloat(2))
        textProperties.xMargin = TractCallToAction.paddingConstant
        textProperties.yMargin = TractCallToAction.paddingConstant
        textProperties.textColor = self.textColor
        
        return textProperties
    }

}
