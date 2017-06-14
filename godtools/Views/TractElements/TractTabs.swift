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
    
    // MARK: - Positions and Sizes
    
    override var width: CGFloat {
        return (self.parent?.width)! - (TractTabs.xMarginConstant * CGFloat(2))
    }
    
    // MARK - Setup
    
    var segmentedControl = UISegmentedControl()
    var tabs = [[XMLIndexer]]()
    
    override func propertiesKind() -> TractProperties.Type {
        return TractTabsProperties.self
    }
    
    override func setupElement(data: XMLIndexer, startOnY yPosition: CGFloat) {
        let contentElements = self.xmlManager.getContentElements(data)
        self.elementFrame.y = yPosition
        
        getTabsLabels(data: data)
        buildTabs()
        setupView(properties: contentElements.properties)
    }
    
    override func setupView(properties: [String: Any]) {
        super.setupView(properties: properties)
        setupSegmentedControl()
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = TractTabs.xMarginConstant
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
        self.elementFrame.yMarginTop = TractTabs.yMarginConstant
    }
    
    // MARK - Helpers
    
    func tabsProperties() -> TractTabsProperties {
        return self.properties as! TractTabsProperties
    }

}
