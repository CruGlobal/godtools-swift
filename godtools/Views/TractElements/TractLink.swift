//
//  TractLink.swift
//  godtools
//
//  Created by Devserker on 5/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractLink: TractButton {
    
    // MARK: - Setup
    
    override func textStyle() -> TractTextContentProperties {
        let textStyle = super.textStyle()
        textStyle.font = .gtRegular(size: 16.0)
        return textStyle
    }
    
    override func loadElementProperties(_ properties: [String: Any]) {
        super.loadElementProperties(properties)
        
        let properties = buttonProperties()
        properties.backgroundColor = .clear
        properties.color = self.manifestProperties.primaryColor
    }

}
