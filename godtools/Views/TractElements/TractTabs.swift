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
    
    var xPosition: CGFloat {
        return 0.0
    }
    var yPosition: CGFloat {
        return self.yStartPosition
    }
    override var height: CGFloat {
        get {
            return super.height + 120.0
        }
        set {
            super.height = newValue
        }
    }
    
    var segmentedControl = UISegmentedControl()
    var options = [String]()
    var tabs = [XMLIndexer]()
    
    override func setupElement(data: XMLIndexer, startOnY yPosition: CGFloat) {
        self.yStartPosition = yPosition
        let dataContent = splitData(data: data)
        
        for option in data["options"].children {
            let text = (option.children.first?.element?.text)! as String
            self.options.append(text)
        }
        
        for tab in data["tab-content"].children {
            self.tabs.append(tab)
        }
        
        buildChildrenForData(dataContent.children)
        setupView(properties: dataContent.properties)
    }
    
    override func setupView(properties: [String: Any]) {
        self.frame = buildFrame()
        setupSegmentedControl()
    }
    
    func setupSegmentedControl() {
        let width = self.width
        let height = CGFloat(28.0)
        let frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        
        self.segmentedControl = UISegmentedControl(frame: frame)
        for i in 0..<self.options.count {
            self.segmentedControl.insertSegment(withTitle: self.options[i], at: i, animated: true)
        }
        
        self.addSubview(segmentedControl)
    }
    
    override func buildChildrenForData(_ data: [XMLIndexer]) {
        var currentYPosition: CGFloat = 28.0
        var elements = [BaseTractElement]()
        
        for tab in self.tabs {
            let element = buildElementForDictionary(tab, startOnY: currentYPosition)
            currentYPosition = element.yEndPosition()
            elements.append(element)
        }
        
        self.height = currentYPosition
        self.elements = elements
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height
    }
    
    // MARK: - Helpers
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }

}
