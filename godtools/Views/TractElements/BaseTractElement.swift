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
    var yEndPosition: CGFloat = 0.0
    var view: UIView?
    var children:[BaseTractElement]?
    
    override init() {
        super.init()
    }
    
    init(data: Dictionary<String, Any>, startOnY yPosition: CGFloat) {
        super.init()
        setupView(data: data, startOnY: yPosition)
    }
    
    func render() -> UIView {
        return self.view!
    }
    
    // MARK: - Build content
    
    func setupView(data: Dictionary<String, Any>, startOnY yPosition: CGFloat) {
        let dataContent = splitData(data: data)
        let currentYPosition = yPosition
        
        //setup view (work with: dataContent.properties)
        
        //setup children
        self.children = buildChildrenForData(dataContent.children, startOnY: currentYPosition)
    }
    
    func buildContentForDictionary(_ data: Dictionary<String, Any>, startOnY yPosition: CGFloat) -> BaseTractElement {
        let dataContent = splitData(data: data)
        var item:BaseTractElement?
        
        if dataContent.kind == "hero" {
            item = Hero(data: data, startOnY: yPosition)
        }
        
        return item!
    }
    
    func buildChildrenForData(_ data: Array<Dictionary<String, Any>>, startOnY yPosition: CGFloat) -> Array<BaseTractElement> {
        var currentYPosition = yPosition
        var children:Array = [BaseTractElement]()
        
        for dictionary in data {
            let item = buildContentForDictionary(dictionary, startOnY: currentYPosition)
            currentYPosition = item.yEndPosition
            children.append(item)
        }
        
        return children
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
}
