//
//  TractTabs.swift
//  godtools
//
//  Created by Devserker on 5/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

class TractTabs: BaseTractElement {
    
    // MARK: Positions constants
    
    static let xMarginConstant: CGFloat = 16.0
    static let yMarginConstant: CGFloat = 16.0
    
    // MARK - Setup
    
    var segmentedControl = UISegmentedControl()
    var tabs = [[XMLIndexer]]()
    
    override func propertiesKind() -> TractProperties.Type {
        return TractTabsProperties.self
    }
    
    override func setupElement(data: XMLIndexer, startOnY yPosition: CGFloat) {
        self.elementFrame.y = yPosition
        
        let contentElements = self.xmlManager.getContentElements(data)
        
        loadElementProperties(contentElements.properties)
        loadFrameProperties()
        
        getTabsLabels(data: data)
        buildTabs()
        setupView(properties: contentElements.properties)
    }
    
    override func setupView(properties: [String: Any]) {
        super.setupView(properties: properties)
        setupSegmentedControl()
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.width = self.parentWidth()
        self.elementFrame.height = self.height
        self.elementFrame.yMarginTop = TractTabs.yMarginConstant
        self.elementFrame.xMargin = 0.0
    }
    
    // MARK - Helpers
    
    func tabsProperties() -> TractTabsProperties {
        return self.properties as! TractTabsProperties
    }

}
