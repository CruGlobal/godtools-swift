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
    
    var height: CGFloat = 0.0
    var width: CGFloat {
        if (self.parent != nil) {
            return self.parent!.width
        } else {
            return BaseTractElement.screenWidth
        }
    }
    
    func getMaxHeight() -> CGFloat {
        if self.elementFrame.maxHeight > 0.0 {
            return self.elementFrame.maxHeight
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
    
    private var _mainView: TractPage?
    var page: TractPage? {
        get {
            return self._mainView != nil ? self._mainView : self.parent!.page
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
    
    var manifestProperties = ManifestProperties()
    
    var horizontalContainer: Bool {
        return false
    }
    
    var xmlManager = XMLManager()
    var elementFrame: TractElementFrame = TractElementFrame()
        
    // MARK: - Initializers
    
    init(children: [XMLIndexer], startOnY yPosition: CGFloat, parent: BaseTractElement) {
        let frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
        super.init(frame: frame)
        self.parent = parent
        self.elementFrame.y = yPosition
        buildChildrenForData(children)
        setupView(properties: [String: Any]())
    }
    
    init(startWithData data: XMLIndexer, withMaxHeight height: CGFloat, manifestProperties: ManifestProperties, configurations: TractConfigurations) {
        let frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
        super.init(frame: frame)
        self.tractConfigurations = configurations
        
        if self.isKind(of: TractPage.self) {
            self._mainView = self as? TractPage
        }
        
        self.elementFrame.maxHeight = height
        setupElement(data: data, startOnY: 0.0)
    }
    
    required init(data: XMLIndexer, parent: BaseTractElement) {
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
    
    required init(data: XMLIndexer, startOnY yPosition: CGFloat, parent: BaseTractElement) {
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
        self.elementFrame.y = yPosition
        
        let contentElements = self.xmlManager.getContentElements(data)
        
        loadElementProperties(contentElements.properties)
        buildChildrenForData(contentElements.children)
        setupView(properties: contentElements.properties)
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
            
            if self.horizontalContainer && element.elementFrame.yEndPosition() > maxYPosition {
                maxYPosition = element.elementFrame.yEndPosition()
            } else {
                currentYPosition = element.elementFrame.yEndPosition()
            }
        }
        
        if self.isKind(of: TractPage.self) && !self.didFindCallToAction && !(self.tractConfigurations!.pagination?.didReachEnd())! {
            let element = TractCallToAction(children: [XMLIndexer](), startOnY: currentYPosition, parent: self)
            currentYPosition = element.elementFrame.yEndPosition()
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
    
    func loadStyles() { }
    
    func loadFrameProperties() { }
    
    func buildFrame() -> CGRect {
        loadFrameProperties()
        return self.elementFrame.getFrame()
    }
    
    func render() -> UIView {
        for element in self.elements! {
            self.addSubview(element.render())
        }
        
        TractBindings.addBindings(self)
        return self
    }
    
    // MARK: - Style properties
    
    private var _properties: TractProperties?
    var properties: TractProperties {
        get {
            if _properties == nil {
                _properties = propertiesKind().init()
            }
            return _properties!
        }
        set {
            if _properties == nil {
                _properties = newValue
            }
        }
    }
    
    func textStyle() -> TractTextContentProperties {
        return self.properties.getTextProperties()
    }
    
    func buttonStyle() -> TractButtonProperties {
        let buttonStyle = TractButtonProperties()
        return buttonStyle
    }
}

extension BaseTractElement {
    
    func propertiesKind() -> TractProperties.Type {
        fatalError("propertiesKind() has not been implemented")
    }
    
    func loadElementProperties(_ properties: [String: Any]) {
        self.properties = propertiesKind().init()
        self.properties.setupDefaultProperties(properties: getParentProperties())
        self.properties.load(properties)
    }
    
    func getParentProperties() -> TractProperties {
        if self.parent != nil {
            return self.parent!.properties
        } else {
            return self.manifestProperties
        }
    }
    
}
