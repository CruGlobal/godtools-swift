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
    
    static let standardMarginConstant: CGFloat = 24.0
    static let modalMarginConstant: CGFloat = 50.0
    static let textPaddingConstant: CGFloat = 8.0
    
    // MARK: - Object properties
    
    var button: GTButton = GTButton()
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractButtonProperties.self
    }
    
    override func loadElementProperties(_ properties: [String: Any]) {
        super.loadElementProperties(properties)
        
        let properties = buttonProperties()
        
        properties.backgroundColor = properties.buttonColor ?? self.manifestProperties.primaryColor
        properties.buttonTextColor = .gtWhite
        
        // This is here to check we are not setting the text and background to both white
        if properties.backgroundColor.isEqual(UIColor.gtWhite) {
            properties.buttonTextColor = UIColor.gtBlack
        }
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
        self.elementFrame.x = 0.0
        self.elementFrame.width = parentWidth()
        self.elementFrame.yMarginTop = 0
    }
    
    override func render() -> UIView {
        if self.elements?.count == 1 && (self.elements?.first?.isKind(of: TractTextContent.self))! {
            let properties = buttonProperties()
            let element = self.elements?.first as! TractTextContent
            let label = element.label
            
            self.button.setTitle(label.text, for: .normal)
            self.button.titleLabel?.font = label.font

            let textColorProperty = properties.buttonTextColor ?? .gtWhite
            self.button.setTitleColor(textColorProperty, for: .normal)
            self.button.setTitleColor(textColorProperty.withAlphaComponent(0.5), for: .highlighted)

            self.button.titleLabel?.lineBreakMode = .byWordWrapping
            self.button.titleLabel?.textAlignment = .center
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
        properties.xMargin = TractButton.textPaddingConstant
        properties.yMargin = 0.0
        properties.height = 22.0
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
