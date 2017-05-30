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
    
    var textPadding: CGFloat = 8.0
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height + self.yMargin
    }
    
    override func textYPadding() -> CGFloat {
        return (self.parent?.textYPadding())!
    }
    
    // MARK: - Object properties
    
    var button: GTButton = GTButton()
    var properties = TractButtonProperties()
    
    // MARK: - Setup
    
    override func setupView(properties: [String: Any]) {
        loadStyles()
        loadElementProperties(properties: properties)
        
        self.button = GTButton()
        if BaseTractElement.isModalElement(self) {
            configureAsModalButton()
        } else {
            configureAsStandardButton()
        }
        
        self.addTargetToButton()
        
        self.addSubview(self.button)
    }
    
    override func render() -> UIView {
        if self.elements?.count == 1 && (self.elements?.first?.isKind(of: TractTextContent.self))! {
            let element = self.elements?.first as! TractTextContent
            let label = element.label
            
            self.button.setTitle(label.text, for: .normal)
            self.button.titleLabel?.font = label.font
            self.button.setTitleColor(self.properties.color, for: .normal)
            self.button.setTitleColor(self.properties.color.withAlphaComponent(0.5), for: .highlighted)
        } else {
            for element in self.elements! {
                self.addSubview(element.render())
            }
        }
        
        TractBindings.addBindings(self)
        return self
    }
    
    override func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }
    
    // MARK: - Helpers
    
    func configureAsModalButton() {
        self.height = self.properties.height + (TractButton.modalMarginConstant * CGFloat(2))
        self.button.designAsTractModalButton()
        
        self.frame = buildFrame()
        self.button.frame = CGRect(x: self.buttonXPosition,
                                   y: TractButton.modalMarginConstant,
                                   width: self.buttonWidth,
                                   height: self.properties.height)
    }
    
    func configureAsStandardButton() {
        self.height = self.properties.height
        button.cornerRadius = self.properties.cornerRadius
        button.backgroundColor = self.properties.backgroundColor
        
        self.frame = buildFrame()
        self.button.frame = CGRect(x: self.buttonXPosition, y: 0.0, width: self.buttonWidth, height: self.height)
        
    }
    
    override func textStyle() -> TractTextContentProperties {
        let textStyle = super.textStyle()
        textStyle.font = .gtRegular(size: 18.0)
        textStyle.width = self.buttonWidth
        textStyle.align = .center
        textStyle.color = self.properties.color
        textStyle.xMargin = self.buttonXPosition
        textStyle.yMargin = self.textPadding
        return textStyle
    }
    
    func loadStyles() {
        self.properties = (self.parent?.buttonStyle())!
    }
    
    func loadElementProperties(properties: [String: Any]) {
        self.properties.load(properties)
        self.properties.backgroundColor = self.primaryColor!
        self.properties.color = .gtWhite
    }
    
    func addTargetToButton() {
        if self.properties.type == .event {
            self.button.addTarget(self, action: #selector(buttonTarget), for: .touchUpInside)
        }
    }
    
    func buttonTarget() {
        let values = self.properties.value!.components(separatedBy: ",")
        for value in values {
            sendMessageToElement(tag: value)
        }
    }

}
