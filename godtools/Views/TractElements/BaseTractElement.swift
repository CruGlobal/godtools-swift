//
//  BaseTractElement.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

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
    
    init(data: Dictionary<String, Any>, startOnY yPosition: CGFloat) {
        super.init()
        setupElement(data: data, startOnY: yPosition)
    }
    
    func render() -> UIView {
        for element in self.elements! {
            self.view!.addSubview(element.render())
        }
        return self.view!
    }
    
    // MARK: - Build content
    
    func setupElement(data: Dictionary<String, Any>, startOnY yPosition: CGFloat) {
        self.yStartPosition = yPosition
        let dataContent = splitData(data: data)
        buildChildrenForData(dataContent.children)
        setupView(properties: dataContent.properties)
    }
    
    func setupView(properties: Dictionary<String, Any>) {
        preconditionFailure("This function must be overridden")
    }
    
    func buildChildrenForData(_ data: Array<Dictionary<String, Any>>) {
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
    
    func buildElementForDictionary(_ data: Dictionary<String, Any>, startOnY yPosition: CGFloat) -> BaseTractElement {
        let dataContent = splitData(data: data)
        var element:BaseTractElement?
        
        if dataContent.kind == "hero" {
            element = Hero(data: data, startOnY: yPosition)
        }
        
        return element!
    }
    
    // MARK: - Helpers
    
    func splitData(data: Dictionary<String, Any>) -> (kind: String, properties: Dictionary<String, Any>, children: Array<Dictionary<String, Any>>) {
        let kind = data["kind"] as! String
        let properties = data["properties"] as! Dictionary<String, Any>
        let children = data["children"] as! Array<Dictionary<String, Any>>
        return (kind, properties, children)
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
    
    func yEndPosition() -> CGFloat {
        return self.yStartPosition + self.height
    }
}
