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

class BaseTractElement: UIView {
    struct Standards {
        static let xMargin = CGFloat(8.0)
        static let yMargin = CGFloat(8.0)
        static let xPadding = CGFloat(0.0)
        static let yPadding = CGFloat(0.0)
        
        static let screenWidth = UIScreen.main.bounds.size.width
        static let textContentWidth = UIScreen.main.bounds.size.width - xMargin * CGFloat(2)
    }
    
    weak var parent: BaseTractElement?
    var elements:[BaseTractElement]?
    var yStartPosition: CGFloat = 0.0
    var maxHeight: CGFloat = 0.0
    private var _height: CGFloat = 0.0
    var height: CGFloat {
        get {
            return _height
        }
        set {
            _height = newValue
        }
    }
    var width: CGFloat {
        return BaseTractElement.Standards.screenWidth
    }
    var horizontalContainer: Bool {
        return false
    }
    var hasCardContainer = false
    
    // MARK: - Initializers
    
    init(children: [XMLIndexer], startOnY yPosition: CGFloat, parent: BaseTractElement) {
        let frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
        super.init(frame: frame)
        self.parent = parent
        self.yStartPosition = yPosition
        buildChildrenForData(children)
        setupView(properties: Dictionary<String, Any>())
    }
    
    init(data: XMLIndexer, withMaxHeight height: CGFloat) {
        let frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
        super.init(frame: frame)
        self.maxHeight = height
        setupElement(data: data, startOnY: 0.0)
    }
    
    init(data: XMLIndexer, startOnY yPosition: CGFloat) {
        let frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
        super.init(frame: frame)
        setupElement(data: data, startOnY: yPosition)
    }
    
    init(data: XMLIndexer, startOnY yPosition: CGFloat, parent: BaseTractElement) {
        let frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
        super.init(frame: frame)
        self.parent = parent
        setupElement(data: data, startOnY: yPosition)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Build content
    
    func render() -> UIView {
        for element in self.elements! {
            self.addSubview(element.render())
        }
        return self
    }
    
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
        var maxYPosition: CGFloat = 0.0
        var elements:Array = [BaseTractElement]()
        
        for dictionary in data {
            let dataContent = splitData(data: dictionary)
            if dataContent.kind == "card" && !self.isKind(of: Cards.self) {
                self.hasCardContainer = true
                break
            }
            
            let element = buildElementForDictionary(dictionary, startOnY: currentYPosition)
            if self.horizontalContainer && element.yEndPosition() > maxYPosition {
                maxYPosition = element.yEndPosition()
            } else {
                currentYPosition = element.yEndPosition()
            }
            
            elements.append(element)
        }
        
        if self.hasCardContainer {
            let cards = getCardsFromXML(data)
            let element = buildCardContainer(cards, startOnY: currentYPosition)
            currentYPosition = element.yEndPosition()
            elements.append(element)
        }
        
        if self.horizontalContainer && !self.hasCardContainer {
            self.height = maxYPosition
        } else {
            self.height = currentYPosition
        }
        
        self.elements = elements
    }
    
    func buildCardContainer(_ data: [XMLIndexer], startOnY yPosition: CGFloat) -> BaseTractElement {
        let element = Cards(children: data, startOnY: yPosition, parent: self)
        return element
    }
    
    func textStyle() -> (style: String, width: CGFloat, height: CGFloat) {
        return ("blackText", BaseTractElement.Standards.textContentWidth, 0.0)
    }
    
    func textYPadding() -> CGFloat {
        return BaseTractElement.Standards.yPadding
    }
    
    // MARK: - Helpers
    
    func yEndPosition() -> CGFloat {
        return self.yStartPosition + self.height
    }
    
    func getMaxHeight() -> CGFloat {
        if self.maxHeight > 0.0 {
            return self.maxHeight
        } else if (self.parent != nil) {
            return (self.parent?.getMaxHeight())!
        } else {
            return 0.0
        }
    }
}
