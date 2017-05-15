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
    
    static let xMargin: CGFloat = 8.0
    static let yMargin: CGFloat = 8.0
    static let xPadding: CGFloat = 0.0
    static let yPadding: CGFloat = 0.0
    static let screenWidth = UIScreen.main.bounds.size.width
    static let textContentWidth = UIScreen.main.bounds.size.width - BaseTractElement.xMargin * CGFloat(2)
    
    private var _tractConfigurations: TractConfigurations?
    var tractConfigurations: TractConfigurations? {
        get {
            let parentTractConfigurations = self.parent?.tractConfigurations
            return self._tractConfigurations != nil ? self._tractConfigurations : parentTractConfigurations
        }
        set {
            self._tractConfigurations = newValue
        }
    }
    weak var parent: BaseTractElement?
    var elements:[BaseTractElement]?
    var didFindCallToAction: Bool = false
    
    var colors: TractColors?
    var primaryColor: UIColor? {
        get {
            return (self.colors != nil ? self.colors?.primaryColor : self.parent?.primaryColor)!
        }
    }
    var primaryTextColor: UIColor {
        get {
            return (self.colors != nil ? self.colors?.primaryTextColor : self.parent?.primaryTextColor)!
        }
    }
    var textColor: UIColor {
        get {
            return (self.colors != nil ? self.colors?.textColor : self.parent?.textColor)!
        }
    }
    
    var yStartPosition: CGFloat = 0.0
    var maxHeight: CGFloat = 0.0
    var height: CGFloat = 0.0
    var width: CGFloat {
        if (self.parent != nil) {
            return self.parent!.width
        } else {
            return BaseTractElement.screenWidth
        }
    }
    var horizontalContainer: Bool {
        return false
    }
    
    fileprivate var _backgroundImagePath: String?
    var backgroundImagePath: String {
        if self._backgroundImagePath != nil {
            return self._backgroundImagePath!
        } else if self.parent != nil {
            return (self.parent?.backgroundImagePath)!
        } else {
            return ""
        }
    }
    
    // MARK: - Initializers
    
    init(children: [XMLIndexer], startOnY yPosition: CGFloat, parent: BaseTractElement) {
        let frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
        super.init(frame: frame)
        self.parent = parent
        self.yStartPosition = yPosition
        buildChildrenForData(children)
        setupView(properties: [String: Any]())
    }
    
    
    // Initializer used only for Root component
    init(startWithData data: XMLIndexer, withMaxHeight height: CGFloat, colors: TractColors, configurations: TractConfigurations) {
        let frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
        super.init(frame: frame)
        self.maxHeight = height
        self.colors = colors
        self.tractConfigurations = configurations
        
        if data.element?.attribute(by: "background-image") != nil {
            self._backgroundImagePath = data.element?.attribute(by: "background-image")?.text
        }
        
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
        var elements = [BaseTractElement]()
        
        for dictionary in data {
            let element = buildElementForDictionary(dictionary, startOnY: currentYPosition)
            if self.horizontalContainer && element.yEndPosition() > maxYPosition {
                maxYPosition = element.yEndPosition()
            } else {
                currentYPosition = element.yEndPosition()
            }
            
            elements.append(element)
        }
        
        if self.isKind(of: TractRoot.self) {
            if !self.didFindCallToAction {
                let element = CallToAction(children: [XMLIndexer](), startOnY: currentYPosition, parent: self)
                if self.horizontalContainer && element.yEndPosition() > maxYPosition {
                    maxYPosition = element.yEndPosition()
                } else {
                    currentYPosition = element.yEndPosition()
                }
                
                elements.append(element)
            }
        }
        
        if self.horizontalContainer {
            self.height = maxYPosition
        } else {
            self.height = currentYPosition
        }
        
        self.elements = elements
    }
    
    func textStyle() -> TextStyle {
        let textStyle = TextStyle()
        textStyle.alignment = (self.tractConfigurations?.defaultTextAlignment)!
        return textStyle
    }
    
    func textYPadding() -> CGFloat {
        return BaseTractElement.yPadding
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
