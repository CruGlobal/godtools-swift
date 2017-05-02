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
    var elements:[BaseTractElement]?
    var view: UIView?
    var yStartPosition: CGFloat = 0.0
    var height: CGFloat = 0.0
    var width: CGFloat {
        return BaseTractElement.Standards.screenWidth
    }
    
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
    
    func textStyle() -> (style: String, width: CGFloat, height: CGFloat) {
        return ("blackText", BaseTractElement.Standards.textContentWidth, 0.0)
    }
    
    func getDimensions() -> (width: CGFloat, height: CGFloat) {
        return (self.width, self.height)
    }
    
    // MARK: - Helpers
    
    func yEndPosition() -> CGFloat {
        return self.yStartPosition + self.height
    }
}
