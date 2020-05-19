//
//  TractLabel.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash

class TractLabel: BaseTractElement {
    
    // MARK: - Object properties
    
    var tapView = UIView()
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractLabelProperties.self
    }
    
    override func loadElementProperties(_ properties: [String : Any]) {
        super.loadElementProperties(properties)
        self.properties.textColor = self.properties.primaryColor
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.width = self.parentWidth()
        self.elementFrame.yMarginTop = 0.0
        self.elementFrame.yMarginBottom = 8.0
        
        if !BaseTractElement.isFormElement(self) {
            self.elementFrame.xMargin = TractCard.xPaddingConstant
        }
    }
    
    override func render() -> UIView {
        for element in self.elements! {
            self.addSubview(element.render())
        }
        
        if !BaseTractElement.isFormElement(self) {
            setupPressGestures()
            buildHorizontalLine()
        }
        
        TractBindings.addBindings(self)
        return self
    }
    
    override func textStyle() -> TractTextContentProperties {
        let properties = super.textStyle()
        properties.width = self.elementFrame.finalWidth()
        properties.xMargin = 0.0
        properties.yMargin = BaseTractElement.yMargin
        
        if BaseTractElement.isFormElement(self) {
            properties.font = .gtRegular(size: 16.0)
        } else {
            properties.font = .gtSemiBold(size: 18.0)
            properties.textColor = properties.primaryColor
        }
        
        return properties
    }
    
    // MARK: - Helpers
    
    func labelProperties() -> TractLabelProperties {
        return self.properties as! TractLabelProperties
    }
}

// MARK: - Gestures

extension TractLabel {
    
    func setupPressGestures() {
        if (self.parent?.isKind(of: TractCard.self))! {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            
            let frame = CGRect(x: 0.0,
                               y: 0.0,
                               width: self.width,
                               height: 60.0)
            self.tapView.frame = frame
            self.tapView.addGestureRecognizer(tapGesture)
            self.tapView.isUserInteractionEnabled = true
            self.addSubview(self.tapView)
        }
    }
    
    @objc func handleGesture(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let cardView = self.parent as! TractCard
            cardView.processCardWithState()
        }
    }
}

// MARK: - UI

extension TractLabel {
    
    func buildHorizontalLine() {
        let height: CGFloat = 1.0
        let yPosition = self.frame.size.height - height
        let horizontalLine = UIView()
        horizontalLine.frame = CGRect(x: 0.0,
                                      y: yPosition,
                                      width: self.elementFrame.finalWidth(),
                                      height: height)
        horizontalLine.backgroundColor = .gtGreyLight
        self.addSubview(horizontalLine)
        
    }
}
