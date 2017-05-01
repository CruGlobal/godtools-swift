//
//  BaseTractElement.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash

class BaseTractElement: NSObject {
    struct Standards {
        static let xPadding = CGFloat(20.0)
        static let yPadding = CGFloat(5.0)
        
        static let screenWidth = UIScreen.main.bounds.size.width
        static let textContentWidth = UIScreen.main.bounds.size.width - xPadding * CGFloat(2)
    }
    
    weak var parent: BaseTractElement?
    var yStartPosition: CGFloat = 0.0
    var height: CGFloat = 0.0
    var view: UIView?
    var elements:[BaseTractElement]?
    
    init(data: XMLIndexer, startOnY yPosition: CGFloat) {
        super.init()
        setupElement(data: data, startOnY: yPosition)
    }
    
    init(data: XMLIndexer, startOnY yPosition: CGFloat, parent: BaseTractElement) {
        super.init()
        self.parent = parent
        setupElement(data: data, startOnY: yPosition)
    }
    
    func render() -> UIView {
        for element in self.elements! {
            self.view!.addSubview(element.render())
        }
        return self.view!
    }
    
    // MARK: - Build content
    
    func setupElement(data: XMLIndexer, startOnY yPosition: CGFloat) {
        self.yStartPosition = yPosition
        let dataContent = splitData(data: data)
        buildChildrenForData(dataContent.children)
        setupView(properties: dataContent.properties)
    }
    
    func setupView(properties: Dictionary<String, Any>) {
        preconditionFailure("This function must be overridden")
    }
    
    func buildChildrenForData(_ data: [XMLIndexer]) {
        var currentYPosition: CGFloat = 0.0
        var elements:Array = [BaseTractElement]()
        
        for dictionary in data {
            let element = buildElementForDictionary(dictionary, startOnY: currentYPosition)
            currentYPosition = element.yEndPosition()
            elements.append(element)
        }
        
        self.height = currentYPosition
        self.elements = elements
    }
    
    func buildElementForDictionary(_ data: XMLIndexer, startOnY yPosition: CGFloat) -> BaseTractElement {
        let dataContent = splitData(data: data)
        var element:BaseTractElement?
        
        if dataContent.kind == "page" {
            element = TractRoot(data: data, startOnY: yPosition, parent: self)
        } else if dataContent.kind == "hero" {
            element = Hero(data: data, startOnY: yPosition, parent: self)
        }else if dataContent.kind == "heading" {
            element = Heading(data: data, startOnY: yPosition, parent: self)
        }else if dataContent.kind == "paragraph" {
            element = Paragraph(data: data, startOnY: yPosition, parent: self)
        }else if dataContent.kind == "content:text" {
            element = TextContent(data: data, startOnY: yPosition, parent: self)
        } else {
            element = TractRoot(data: data, startOnY: yPosition, parent: self)
        }
        
        return element!
    }
    
    // MARK: - Helpers
    
    func splitData(data: XMLIndexer) -> (kind: String, properties: Dictionary<String, Any>, children: [XMLIndexer]) {
        let kind = data.element?.name
        var properties = Dictionary<String, Any>()
        for item in (data.element?.allAttributes)! {
            let attribute = item.value as XMLAttribute
            properties[attribute.name] = attribute.text
        }
        properties["value"] = data.element?.text
        let children = data.children
        return (kind!, properties, children)
    }
    
    static func isParagraphElement(_ element: BaseTractElement) -> Bool {
        var elementCopy: BaseTractElement? = element
        
        while elementCopy != nil {
            if elementCopy!.isKind(of: Paragraph.self) {
                return true
            }
            elementCopy = elementCopy!.parent
        }
        
        return false
    }
    
    static func isHeadingElement(_ element: BaseTractElement) -> Bool {
        var elementCopy: BaseTractElement? = element
        
        while elementCopy != nil {
            if elementCopy!.isKind(of: Heading.self) {
                return true
            }
            elementCopy = elementCopy!.parent
        }
        
        return false
    }
    
    func yEndPosition() -> CGFloat {
        return self.yStartPosition + self.height
    }
}
