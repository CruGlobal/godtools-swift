//
//  TractButton.swift
//  godtools
//
//  Created by Devserker on 5/11/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import Crashlytics

class TractButton: BaseTractElement {
    
    // MARK: Positions constants
    
    static let modalMarginConstant: CGFloat = 50.0
    
    // MARK: - Positions and Sizes
    
    var xMargin: CGFloat {
        return TractCard.xPaddingConstant
    }
    
    var yMargin : CGFloat {
        return buttonProperties().yMargin
    }
    
    var xPosition: CGFloat {
        return self.xMargin
    }
    
    override var width: CGFloat {
        return super.width - self.xPosition - self.xMargin
    }
    
    var buttonWidth: CGFloat {
        return buttonProperties().width > self.width ? self.width : buttonProperties().width
    }
    
    var buttonXPosition: CGFloat {
        return (self.width - self.buttonWidth) / 2
    }
    
    var textPadding: CGFloat = 8.0
    
    override func textYPadding() -> CGFloat {
        return (self.parent?.textYPadding())!
    }
    
    // MARK: - Object properties
    
    var button: GTButton = GTButton()
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractButtonProperties.self
    }
    
    override func loadElementProperties(_ properties: [String: Any]) {
        super.loadElementProperties(properties)
        
        let properties = buttonProperties()
        properties.backgroundColor = self.manifestProperties.primaryColor
        properties.color = .gtWhite
    }
    
    override func loadStyles() {
        self.button = GTButton()
        if BaseTractElement.isModalElement(self) {
            configureAsModalButton()
        } else {
            configureAsStandardButton()
        }
        
        self.addTargetToButton()
        
        self.addSubview(self.button)
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = self.xPosition
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
        self.elementFrame.yMarginTop = yMargin
        self.elementFrame.yMarginBottom = yMargin
    }
    
    override func render() -> UIView {
        if self.elements?.count == 1 && (self.elements?.first?.isKind(of: TractTextContent.self))! {
            let properties = buttonProperties()
            let element = self.elements?.first as! TractTextContent
            let label = element.label
            
            self.button.setTitle(label.text, for: .normal)
            self.button.titleLabel?.font = label.font
            self.button.setTitleColor(properties.color, for: .normal)
            self.button.setTitleColor(properties.color.withAlphaComponent(0.5), for: .highlighted)
        } else {
            for element in self.elements! {
                self.addSubview(element.render())
            }
        }
        
        TractBindings.addBindings(self)
        return self
    }
    
    override func textStyle() -> TractTextContentProperties {
        let properties = self.properties.getTextProperties()
        properties.xMargin = self.buttonXPosition
        properties.yMargin = self.textPadding
        return properties
    }
    
    // MARK: - Helpers
    
    func addTargetToButton() {
        let properties = buttonProperties()
        
        if properties.type == .event || properties.type == .url {
            self.button.addTarget(self, action: #selector(buttonTarget), for: .touchUpInside)
        }
    }
    
    func buttonProperties() -> TractButtonProperties {
        return self.properties as! TractButtonProperties
    }

}
