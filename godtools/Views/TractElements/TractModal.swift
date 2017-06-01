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
    
    // MARK: - Positions and Sizes
    
    override func yEndPosition() -> CGFloat {
        return self.height
    }
    
    // MARK: - Object properties
    
    var properties = TractModalProperties()
    var alreadyRendered = false
    
    // MARK: - Setup
    
    override func setupView(properties: [String: Any]) {
        super.setupView(properties: properties)
        TractBindings.addBindings(self)
    }
    
    override func loadStyles() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    override func buildFrame() -> CGRect {
        return (UIApplication.shared.keyWindow?.frame)!
    }
    
    override func render() -> UIView {
        let modalHeight = UIApplication.shared.keyWindow?.frame.size.height
        var startYPosition:CGFloat = 0
        
        if self.alreadyRendered == false {
            startYPosition = (modalHeight! - self.height) / CGFloat(2)
            self.alreadyRendered = true
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
        
        return self
    }
    
    // MARK: - Bindings
    
    override func elementListeners() -> [String]? {
        return self.properties.listeners == nil ? nil : self.properties.listeners?.components(separatedBy: ",")
    }
    
    override func elementDismissListeners() -> [String]? {
        return self.properties.dismissListeners == nil ? nil : self.properties.dismissListeners?.components(separatedBy: ",")
    }
    
    // MARK: - Helpers
    
    override func loadElementProperties(_ properties: [String: Any]) {
        self.properties.load(properties)
    }

}
