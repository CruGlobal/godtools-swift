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
        return self.properties.yMargin
    }
    
    var xPosition: CGFloat {
        return TractCard.xPaddingConstant
    }
    
    var textViewWidth: CGFloat {
        return self.properties.width > self.width ? self.width : self.properties.width
    }
    
    var textViewHeight: CGFloat {
        return self.properties.height
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
    
    var properties = TractInputProperties()
    var textField = GTTextField()
    
    // MARK: - Setup
    
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
                    self.properties.placeholder = textNode?.text
                }
            }
        }
        
        buildChildrenForData(elements)
        setupView(properties: contentElements.properties)
    }
    
    override func setupView(properties: [String: Any]) {
        loadElementProperties(properties)
        
        self.textField.cornerRadius = self.properties.cornerRadius
        self.textField.borderColor = self.properties.color
        self.textField.borderWidth = self.properties.borderWidth
        self.textField.backgroundColor = self.properties.backgroundColor
        self.textField.placeholderTranslationKey = self.properties.placeholder ?? ""
        
        self.frame = buildFrame()
    }
    
    override func loadElementProperties(_ properties: [String: Any]) {
        self.properties.load(properties)
        self.properties.backgroundColor = .gtWhite
        self.properties.color = self.manifestProperties.primaryColor
        self.properties.parentProperties = getParentProperties()
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
    
    override func getElementProperties() -> TractProperties {
        return self.properties
    }

}
