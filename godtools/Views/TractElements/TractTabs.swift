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
    
    var xPosition: CGFloat {
        return TractTabs.xMarginConstant
    }
    
    var yPosition: CGFloat {
        return self.yStartPosition + TractTabs.yMarginConstant
    }
    
    override var width: CGFloat {
        return (self.parent?.width)! - (self.xPosition * CGFloat(2))
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height
    }
    
    // MARK: - Object properties
    
    var segmentedControl = UISegmentedControl()
    var options = [String]()
    var tabs = [[XMLIndexer]]()
    
    // MARK - Setup
    
    var properties = TractTabsProperties()
    
    override func setupElement(data: XMLIndexer, startOnY yPosition: CGFloat) {
        self.yStartPosition = yPosition
        let contentElements = self.xmlManager.getContentElements(data)
        
        var position = 0
        for item in data.children {
            self.tabs.append([XMLIndexer]())
            
            for node in item.children {
                let nodeElements = self.xmlManager.getContentElements(node)
                
                if nodeElements.kind == "label" {
                    let text = node["content:text"].element?.text
                    self.options.append(text!)
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
    
    func loadFrameProperties() {
        self.properties.frame.x = self.xPosition
        self.properties.frame.y = self.yPosition
        self.properties.frame.width = self.width
        self.properties.frame.height = self.height
    }
    
    override func buildFrame() -> CGRect {
        return self.properties.frame.getFrame()
    }
    
    // MARK: - Segmented Control
    
    func setupSegmentedControl() {
        let width = self.width
        let height: CGFloat = 28.0
        let frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        
        self.segmentedControl = UISegmentedControl(frame: frame)
        for i in 0..<self.options.count {
            self.segmentedControl.insertSegment(withTitle: self.options[i], at: i, animated: true)
        }
        
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentedControl.tintColor = self.primaryColor
        self.segmentedControl.addTarget(self, action: #selector(newOptionSelected), for: .valueChanged)
        
        self.addSubview(self.segmentedControl)
    }
    
    func newOptionSelected() {
        for element in self.elements! {
            element.isHidden = true
        }
        self.elements![self.segmentedControl.selectedSegmentIndex].isHidden = false
    }

}
