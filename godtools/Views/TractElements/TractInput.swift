//
//  TractInput.swift
//  godtools
//
//  Created by Devserker on 5/11/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

class TractInput: BaseTractElement {
    
    // MARK: - Positions and Sizes
    
    var yMargin : CGFloat {
        return inputProperties().yMargin
    }
    
    var xPosition: CGFloat {
        return TractCard.xPaddingConstant
    }
    
    var textViewWidth: CGFloat {
        let properties = inputProperties()
        return properties.width > self.width ? self.width : properties.width
    }
    
    var textViewHeight: CGFloat {
        return inputProperties().height
    }
    
    override var width: CGFloat {
        return super.width - self.xPosition - TractCard.xPaddingConstant
    }
    
    override var height: CGFloat {
        get {
            return super.height + self.yMargin + self.textViewHeight
        }
        set {
            super.height = newValue
        }
    }
    
    var textViewXPosition: CGFloat {
        return (self.width - self.textViewWidth) / 2
    }
    
    var textViewYPosition: CGFloat {
        return super.height + self.yMargin
    }
    
    override func textYPadding() -> CGFloat {
        return (self.parent?.textYPadding())!
    }
    
    // MARK: - Object properties
    
    var textField = GTTextField()
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractInputProperties.self
    }
    
    override func setupElement(data: XMLIndexer, startOnY yPosition: CGFloat) {
        self.elementFrame.y = yPosition
        let contentElements = self.xmlManager.getContentElements(data)
        
        var elements = [XMLIndexer]()
        for node in data.children {
            if self.xmlManager.parser.nodeIsLabel(node: node) {
                elements.append(node)
            } else if self.xmlManager.parser.nodeIsPlaceholder(node: node) {
                let textNode = self.xmlManager.parser.getTextContentFromElement(node)
                if textNode != nil {
                    self.inputProperties().placeholder = textNode?.text
                }
            }
        }
        
        buildChildrenForData(elements)
        setupView(properties: contentElements.properties)
    }
    
    override func setupView(properties: [String: Any]) {
        loadElementProperties(properties)
        
        let properties = inputProperties()
        
        self.textField.cornerRadius = properties.cornerRadius
        self.textField.borderColor = properties.color
        self.textField.borderWidth = properties.borderWidth
        self.textField.backgroundColor = properties.backgroundColor
        self.textField.placeholderTranslationKey = properties.placeholder ?? ""
        
        updateFrameHeight()
    }
    
    override func loadElementProperties(_ properties: [String: Any]) {
        super.loadElementProperties(properties)
        let newProperties = inputProperties()
        newProperties.backgroundColor = .gtWhite
        newProperties.color = self.manifestProperties.primaryColor
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = self.xPosition
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
        self.elementFrame.yMarginTop = self.yMargin
        self.elementFrame.yMarginBottom = self.yMargin
    }
    
    override func render() -> UIView {
        for element in self.elements! {
            self.addSubview(element.render())
        }
        
        self.textField.frame = CGRect(x: self.textViewXPosition,
                                      y: self.textViewYPosition,
                                      width: self.textViewWidth,
                                      height: self.textViewHeight)
        self.addSubview(self.textField)
        
        TractBindings.addBindings(self)
        return self
    }
    
    // MARK: - Helpers
    
    private func inputProperties() -> TractInputProperties {
        return self.properties as! TractInputProperties
    }

}
