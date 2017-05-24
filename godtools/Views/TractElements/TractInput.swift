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
    
    var xMargin: CGFloat {
        return TractCard.xPaddingConstant
    }
    
    var yMargin : CGFloat {
        return self.properties.yMargin
    }
    
    var xPosition: CGFloat {
        return self.xMargin
    }
    
    var yPosition: CGFloat {
        return self.yStartPosition + self.yMargin
    }
    
    var textViewWidth: CGFloat {
        return self.properties.width > self.width ? self.width : self.properties.width
    }
    
    var textViewHeight: CGFloat {
        return self.properties.height
    }
    
    override var width: CGFloat {
        return super.width - self.xPosition - self.xMargin
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
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height + self.yMargin
    }
    
    override func textYPadding() -> CGFloat {
        return (self.parent?.textYPadding())!
    }
    
    // MARK: - Object properties
    
    var properties = TractTextFieldProperties()
    var textField = GTTextField()
    
    // MARK: - Setup
    
    override func setupElement(data: XMLIndexer, startOnY yPosition: CGFloat) {
        self.yStartPosition = yPosition
        let dataContent = splitData(data: data)
        
        var elements = [XMLIndexer]()
        for node in data.children {
            let nodeContent = splitData(data: node)
            
            if nodeContent.kind == "label" {
                elements.append(node)
            } else if nodeContent.kind == "placeholder" {
                self.properties.placeholder = node["content:text"].element?.text
            }
        }
        
        buildChildrenForData(elements)
        setupView(properties: dataContent.properties)
    }
    
    override func setupView(properties: [String: Any]) {
        loadElementProperties(properties: properties)
        
        self.textField.cornerRadius = self.properties.cornerRadius
        self.textField.borderColor = self.properties.color
        self.textField.borderWidth = self.properties.borderWidth
        self.textField.backgroundColor = self.properties.backgroundColor
        self.textField.placeholderTranslationKey = self.properties.placeholder ?? ""
        
        self.frame = buildFrame()
    }
    
    override func render() -> UIView {
        for element in self.elements! {
            self.addSubview(element.render())
            addBindings(element)
        }
        
        self.textField.frame = CGRect(x: self.textViewXPosition,
                                      y: self.textViewYPosition,
                                      width: self.textViewWidth,
                                      height: self.textViewHeight)
        self.addSubview(self.textField)
        
        return self
    }
    
    // MARK: - Helpers
    
    func loadElementProperties(properties: [String: Any]) {
        for property in properties.keys {
            switch property {
            case "value":
                self.properties.value = properties[property] as! String?
            case "name":
                self.properties.name = properties[property] as! String?
            case "type":
                self.properties.type = properties[property] as! String?
            default: break
            }
        }
        
        self.properties.backgroundColor = .gtWhite
        self.properties.color = self.primaryColor!
    }
    
    func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }

}
