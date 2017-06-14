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
    
    override func loadFrameProperties() {
        let frame = (UIApplication.shared.keyWindow?.frame)!
        self.elementFrame.x = 0.0
        self.elementFrame.y = 0.0
        self.elementFrame.width = frame.size.width
        self.elementFrame.height = frame.size.height
    }
    
    override func render() -> UIView {
        renderModalElements()
        return self
    }
    
    // MARK: - Bindings
    
    override func elementListeners() -> [String]? {
        let properties = modalProperties()
        return properties.listeners == nil ? nil : properties.listeners?.components(separatedBy: ",")
    }
    
    override func elementDismissListeners() -> [String]? {
        let properties = modalProperties()
        return properties.dismissListeners == nil ? nil : properties.dismissListeners?.components(separatedBy: ",")
    }
    
    // MARK: - Helpers
    
    func modalProperties() -> TractModalProperties {
        return self.properties as! TractModalProperties
    }

}
