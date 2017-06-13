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
    
    var properties = TractTabsProperties()
    var segmentedControl = UISegmentedControl()
    var tabs = [[XMLIndexer]]()
    
    override func setupElement(data: XMLIndexer, startOnY yPosition: CGFloat) {
        self.elementFrame.y = yPosition
        let contentElements = self.xmlManager.getContentElements(data)
        
        var position = 0
        for item in data.children {
            self.tabs.append([XMLIndexer]())
            
            for node in item.children {                
                if self.xmlManager.parser.nodeIsLabel(node: node) {
                    if let textNode = self.xmlManager.parser.getTextContentFromElement(node) {
                        self.properties.options.append(textNode.text!)
                    }
                } else {
                    self.tabs[position].append(node)
                }
            }
            
            position += 1
        }
        
        buildChildrenForData(contentElements.children)
        setupView(properties: contentElements.properties)
    }
    
    override func buildChildrenForData(_ data: [XMLIndexer]) {
        let currentYPosition: CGFloat = 28.0
        var maxHeight: CGFloat = currentYPosition
        var elements = [BaseTractElement]()
        var firstElement = true
        
        for tabData in self.tabs {
            let element = TractTab(children: tabData, startOnY: currentYPosition, parent: self)
            
            if firstElement {
                element.isHidden = false
                firstElement = false
            } else {
                element.isHidden = true
            }
            
            if element.height > maxHeight {
                maxHeight = element.height
            }
            elements.append(element)
        }
        
        self.height = maxHeight
        self.elements = elements
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

}
