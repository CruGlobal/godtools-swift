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
        
        loadElementProperties(contentElements.properties)
        loadFrameProperties()
        buildChildrenForData(elements)
        buildFrame()
        updateFrameHeight()
        setupView(properties: contentElements.properties)
    }
    
    override func setupView(properties: [String: Any]) {
        setupTextField()
    }
    
    func setupTextField() {
        let elementProperties = inputProperties()
        
        self.textField.cornerRadius = elementProperties.cornerRadius
        self.textField.borderColor = elementProperties.color
        self.textField.borderWidth = elementProperties.borderWidth
        self.textField.backgroundColor = elementProperties.backgroundColor
        self.textField.placeholderTranslationKey = elementProperties.placeholder ?? ""
        self.textField.frame = CGRect(x: 0.0,
                                      y: self.height,
                                      width: self.elementFrame.finalWidth(),
                                      height: elementProperties.height)
        
        self.height += elementProperties.height
        updateFrameHeight()
    }
    
    override func loadElementProperties(_ properties: [String: Any]) {
        super.loadElementProperties(properties)
        let newProperties = inputProperties()
        newProperties.backgroundColor = .gtWhite
        newProperties.color = self.manifestProperties.primaryColor
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.width = parentWidth()
    }
    
    override func render() -> UIView {        
        for element in self.elements! {
            self.addSubview(element.render())
        }
        
        self.addSubview(self.textField)
        
        TractBindings.addBindings(self)
        return self
    }
    
    // MARK: - Helpers
    
    private func inputProperties() -> TractInputProperties {
        return self.properties as! TractInputProperties
    }

}
