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
        
        switch elementProperties.type {
        case .email:
            self.textField.keyboardType = .emailAddress
        case .phone:
            self.textField.keyboardType = .phonePad
        default:
            self.textField.keyboardType = .default
        }
        
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
        let properties = inputProperties()
        if properties.type == .hidden {
            self.frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
        } else {
            for element in self.elements! {
                self.addSubview(element.render())
            }
            
            self.addSubview(self.textField)
        }
        
        attachToForm()
        TractBindings.addBindings(self)
        return self
    }
    
    // MARK: - Form Functions
    
    override func formName() -> String {
        let properties = inputProperties()
        return properties.name ?? ""
    }
    
    override func formValue() -> String {
        let properties = inputProperties()
        if properties.type == .hidden {
            return properties.value ?? ""
        } else {
            return self.textField.text!
        }
    }
    
    // MARK: - Helpers
    
    private func inputProperties() -> TractInputProperties {
        return self.properties as! TractInputProperties
    }

}
