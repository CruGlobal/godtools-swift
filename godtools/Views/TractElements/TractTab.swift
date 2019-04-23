//
//  TractTab.swift
//  godtools
//
//  Created by Devserker on 5/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractTab: BaseTractElement {
    
    // MARK: Positions constants
    
    static let xMarginConstant: CGFloat = 0.0
    static let yMarginConstant: CGFloat = 8.0
    
    // MARK: - Object properties
    
    var analyticsTabDictionary: [String: String] = [:]
    private(set) var tabIndex: Int!
        
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractTabProperties.self
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.width = self.parentWidth()
        self.elementFrame.yMarginBottom = TractTab.yMarginConstant
    }
    
    override func elementListeners() -> [String]? {
        let properties = tabProperties()
        return properties.listeners == "" ? nil : properties.listeners.components(separatedBy: ",")
    }

    override func receiveMessage() {
        guard let tabs = self.parent as? TractTabs else { return }
        tabs.selectTab(self.elementNumber)
    }

    // MARK: - Helpers
    
    func tabProperties() -> TractTabProperties {
        return self.properties as! TractTabProperties
    }

}
