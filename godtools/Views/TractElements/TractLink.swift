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
        
        for property in properties.keys {
            switch property {
            case "events":
                self.properties.events = properties[property] as! String?
            default: break
            }
        }
        
        self.properties.backgroundColor = .gtWhite
        self.properties.color = self.primaryColor!
    }
    
    override func addTargetToButton() {
        if self.properties.type == .url {
            self.button.addTarget(self, action: #selector(buttonTarget), for: .touchUpInside)
        }
    }

}
