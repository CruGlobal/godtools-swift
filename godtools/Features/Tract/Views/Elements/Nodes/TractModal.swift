//
//  TractModal.swift
//  godtools
//
//  Created by Devserker on 5/16/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractModal: BaseTractElement {
    
    // MARK: Positions constants
    
    static let contentWidth: CGFloat = 275.0
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractModalProperties.self
    }
    
    override func setupView(properties: [String: Any]) {
        super.setupView(properties: properties)
        TractBindings.addBindings(self)
    }
    
    override func loadStyles() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    override func loadElementProperties(_ properties: [String : Any]) {
        super.loadElementProperties(properties)
        self.properties.textColor = .gtWhite
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.y = 0.0
        self.elementFrame.width = getMaxWidth()
    }
    
    override func render() -> UIView {
        renderModalElements()
        return self
    }
    
    // MARK: - Bindings
    
    override func elementListeners() -> [String]? {
        let properties = modalProperties()
        return properties.listeners == "" ? nil : properties.listeners.components(separatedBy: ",")
    }
    
    override func elementDismissListeners() -> [String]? {
        let properties = modalProperties()
        return properties.dismissListeners == "" ? nil : properties.dismissListeners.components(separatedBy: ",")
    }
    
    // MARK: - Helpers
    
    func modalProperties() -> TractModalProperties {
        return self.properties as! TractModalProperties
    }
}

// MARK: - Actions

extension TractModal {
    
    override func receiveMessage() {
        _ = render()
        
        self.frame = CGRect(x: 0.0,
                            y: 0.0,
                            width: BaseTractElement.screenWidth,
                            height: BaseTractElement.screenHeight)
        
        let currentWindow = UIApplication.shared.keyWindow
        currentWindow?.addSubview(self)
        
        self.alpha = CGFloat(0.0)
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: { self.alpha = CGFloat(1.0) },
                       completion: nil )
    }
    
    override func receiveDismissMessage() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 0.75,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: { self.alpha = CGFloat(0.0) },
                       completion: { (completed: Bool) in
                        self.removeFromSuperview() } )
    }
}

// MARK: - ChildSetup

extension TractModal {
    
    func renderModalElements() {
        let properties = modalProperties()
        let modalHeight = BaseTractElement.screenHeight
        var startYPosition:CGFloat = 0
        
        if properties.alreadyRendered == false {
            startYPosition = (modalHeight - self.height) / CGFloat(2)
            properties.alreadyRendered = true
        }
        
        for element in self.elements! {
            element.removeFromSuperview()
            
            let xPosition = element.frame.origin.x
            let yPosition = element.frame.origin.y + startYPosition
            let width = element.frame.size.width
            let height = element.frame.size.height
            element.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
            self.addSubview(element.render())
        }
    }
}
