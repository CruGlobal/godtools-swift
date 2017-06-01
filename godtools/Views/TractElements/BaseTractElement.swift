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
    
    // MARK: Positions constants
    
    static let xMargin: CGFloat = 8.0
    static let yMargin: CGFloat = 8.0
    static let xPadding: CGFloat = 0.0
    static let yPadding: CGFloat = 0.0
    static let screenWidth = UIScreen.main.bounds.size.width
    static let textContentWidth = UIScreen.main.bounds.size.width - BaseTractElement.xMargin * CGFloat(2)
    
    // MARK: - Positions and Sizes
    
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
    
    func textYPadding() -> CGFloat {
        return BaseTractElement.yPadding
    }
    
    // MARK: Main properties
    
    private var _mainView: TractRoot?
    var root: TractRoot? {
        get {
            return self._mainView != nil ? self._mainView : self.parent!.root
        }
    }
    
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
    
    init(startWithData data: XMLIndexer, withMaxHeight height: CGFloat, colors: TractColors, configurations: TractConfigurations) {
        let frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
        super.init(frame: frame)
        self.yStartPosition = 0.0
        self.maxHeight = height
        self.colors = colors.copyObject()
        self.tractConfigurations = configurations
        
        if data.element?.attribute(by: "background-image") != nil {
            self._backgroundImagePath = data.element?.attribute(by: "background-image")?.text
        }
        
        if self.isKind(of: TractRoot.self) {
            self._mainView = self as? TractRoot
        }
        
        setupElement(data: data, startOnY: 0.0)
    }
    
    init(data: XMLIndexer, parent: BaseTractElement) {
        let frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
        super.init(frame: frame)
        self.parent = parent
        setupElement(data: data, startOnY: CGFloat(0.0))
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
    
    func setupElement(data: XMLIndexer, startOnY yPosition: CGFloat) {
        self.yStartPosition = yPosition
        let dataContent = splitData(data: data)
        loadElementProperties(dataContent.properties)
        buildChildrenForData(dataContent.children)
        setupView(properties: dataContent.properties)
    }
    
    func buildChildrenForData(_ data: [XMLIndexer]) {
        var currentYPosition: CGFloat = 0.0
        var maxYPosition: CGFloat = 0.0
        var elements = [BaseTractElement]()
        
        for dictionary in data {
            let element = buildElementForDictionary(dictionary, startOnY: currentYPosition)
            elements.append(element)
            
            if element.isKind(of: TractCallToAction.self) {
                self.didFindCallToAction = true
            } else if element.isKind(of: TractModals.self) {
                continue
            }
            
            if self.horizontalContainer && element.yEndPosition() > maxYPosition {
                maxYPosition = element.yEndPosition()
            } else {
                currentYPosition = element.yEndPosition()
            }
        }
        
        if self.isKind(of: TractRoot.self) && !self.didFindCallToAction {
            let element = TractCallToAction(children: [XMLIndexer](), startOnY: currentYPosition, parent: self)
            currentYPosition = element.yEndPosition()
            elements.append(element)
        }
        
        if self.horizontalContainer {
            self.height = maxYPosition
        } else {
            self.height = currentYPosition
        }
        
        self.elements = elements
    }
    
    func setupView(properties: Dictionary<String, Any>) {
        self.frame = buildFrame()
        loadStyles()
    }
    
    func loadElementProperties(_ properties: [String: Any]) { }
    
    func loadStyles() { }
    
    func buildFrame() -> CGRect {
        preconditionFailure("This function must be overridden")
    }
    
    func render() -> UIView {
        for element in self.elements! {
            self.addSubview(element.render())
        }
        
        TractBindings.addBindings(self)
        return self
    }
    
    // MARK: - Style properties
    
    func textStyle() -> TractTextContentProperties {
        let textStyle = TractTextContentProperties()
        textStyle.align = (self.tractConfigurations?.defaultTextAlignment)!
        return textStyle
    }
    
    func buttonStyle() -> TractButtonProperties {
        let buttonStyle = TractButtonProperties()
        return buttonStyle
    }
    
}
