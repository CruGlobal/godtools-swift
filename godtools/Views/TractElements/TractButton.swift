//
//  TractButton.swift
//  godtools
//
//  Created by Devserker on 5/11/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractButton: BaseTractElement {
    
    var properties = TractButtonProperties()
    
    var xMargin: CGFloat {
        return self.properties.xMargin
    }
    var yMargin : CGFloat {
        return self.properties.yMargin
    }
    var xPosition: CGFloat {
        return self.xMargin
    }
    var yPosition: CGFloat {
        return self.yStartPosition + self.yMargin
    }
    override var width: CGFloat {
        return super.width - self.xPosition - self.xMargin
    }
    var buttonWidth: CGFloat {
        return self.properties.width > self.width ? self.width : self.properties.width
    }
    var buttonXPosition: CGFloat {
        return (self.width - self.buttonWidth) / 2
    }
    var textPadding = CGFloat(8.0)
    
    var button: GTButton = GTButton()
    
    override func setupView(properties: [String: Any]) {
        loadStyles()
        loadElementProperties(properties: properties)
        self.height = self.properties.height
        
        self.button = GTButton()
        self.button.setTitle(self.properties.value, for: .normal)
        button.cornerRadius = self.properties.cornerRadius
        button.backgroundColor = self.properties.backgroundColor
        
        self.frame = buildFrame()
        self.button.frame = CGRect(x: self.buttonXPosition, y: 0.0, width: self.buttonWidth, height: self.frame.size.height)
        self.addSubview(self.button)
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height + self.yMargin
    }
    
    override func textYPadding() -> CGFloat {
        return (self.parent?.textYPadding())!
    }
    
    // MARK: - Helpers
    
    override func textStyle() -> TextContentProperties {
        let textStyle = super.textStyle()
        textStyle.font = .gtRegular(size: 18.0)
        textStyle.width = self.buttonWidth
        textStyle.align = .center
        textStyle.color = .gtWhite
        textStyle.xMargin = self.buttonXPosition
        textStyle.yMargin = self.textPadding
        return textStyle
    }
    
    func loadStyles() {
        self.properties = (self.parent?.buttonStyle())!
    }
    
    func loadElementProperties(properties: [String: Any]) {
        for property in properties.keys {
            switch property {
            case "value":
                self.properties.value = properties[property] as! String?
            case "i18n-id":
                self.properties.i18nId = properties[property] as! String?
            case "type":
                self.properties.value = properties[property] as! String?
            default: break
            }
        }
    }
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }

}
