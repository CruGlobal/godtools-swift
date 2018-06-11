//
//  TractButton.swift
//  godtools
//
//  Created by Devserker on 5/11/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractButton: BaseTractElement {
    
    // MARK: Positions constants
    
    static let standardMarginConstant: CGFloat = 24.0
    static let modalMarginConstant: CGFloat = 50.0
    static let textPaddingConstant: CGFloat = 8.0
    
    // MARK: - Object properties
    
    var button: GTButton = GTButton()
    var analyticsButtonDictionary: [String: String] = [:]
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractButtonProperties.self
    }
    
    override func loadElementProperties(_ properties: [String: Any]) {
        super.loadElementProperties(properties)
        
        let properties = buttonProperties()
        let pageProperties = page?.pageProperties()
        
        properties.backgroundColor = properties.buttonColor ?? pageProperties?.primaryColor ?? manifestProperties.primaryColor
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

            guard let element = self.elements?.first as? TractTextContent else { return self }
            let label = element.label
            
            self.button.setTitle(label.text, for: .normal)
            self.button.titleLabel?.font = label.font

            let textColorProperty = buttonTextColor(localColor: element.textProperties().localTextColor)
            
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
    
    func buttonTextColor(localColor: UIColor?) -> UIColor {
        return localColor ?? page?.pageProperties().primaryTextColor ?? manifestProperties.primaryTextColor
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
        
        properties.analyticsButtonUserInfo = self.analyticsUserInfo
        debugPrint("self.analyticsButtonDictionary \(self.analyticsUserInfo)\n")
        
        if properties.type == .event || properties.type == .url {
            self.button.addTarget(self, action: #selector(buttonTarget), for: .touchUpInside)
        }
    }
    
    func buttonProperties() -> TractButtonProperties {
        return self.properties as! TractButtonProperties
    }

}
