//
//  TractLink.swift
//  godtools
//
//  Created by Devserker on 5/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractLink: TractButton {
    
    override func textStyle() -> TractTextContentProperties {
        let textStyle = super.textStyle()
        textStyle.font = .gtRegular(size: 16.0)
        return textStyle
    }
    
    override func loadElementProperties(properties: [String: Any]) {
        super.loadElementProperties(properties: properties)
        
        self.properties.backgroundColor = .gtWhite
        self.properties.color = self.primaryColor!
    }

}
