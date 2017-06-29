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

protocol BaseTractElementDelegate: class {
    func showAlert(_ alert: UIAlertController)
    func displayedLanguage() -> Language
}

class BaseTractElement: UIView {
    
    // MARK: Positions constants
    
    static let xMargin: CGFloat = 8.0
    static let yMargin: CGFloat = 8.0
    static let xPadding: CGFloat = 0.0
    static let yPadding: CGFloat = 0.0
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    
    // MARK: - Positions and Sizes
    
    var height: CGFloat = 0.0
    var width: CGFloat {
        if (self.parent != nil) {
            return self.parent!.width
        } else {
            return BaseTractElement.screenWidth
        }
    }
    
    func getMaxWidth() -> CGFloat {
        return BaseTractElement.screenWidth
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
    
    func startingYPos() -> CGFloat {
        return 0.0
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
    var parallelElement: BaseTractElement?
    var elementNumber: Int = -1
    var didFindCallToAction: Bool = false
    
    var _manifestProperties: ManifestProperties = ManifestProperties()
    var manifestProperties: ManifestProperties {
        get {
            if self.parent != nil {
                return self.parent!.manifestProperties
            } else {
                return self._manifestProperties
            }
        }
        set {
            if self.parent != nil {
                self.parent!.manifestProperties = newValue
            } else {
                self._manifestProperties = newValue
            }
        }
    }
    
    var horizontalContainer: Bool {
        return false
    }
    
    var xmlManager = XMLManager()
    var elementFrame: TractElementFrame = TractElementFrame()
    
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
    
    weak private var delegate: BaseTractElementDelegate?
        
    // MARK: - Initializers
    
    init(children: [XMLIndexer], startOnY yPosition: CGFloat, parent: BaseTractElement) {
        let frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
        super.init(frame: frame)
        self.parent = parent
        self.elementFrame.y = yPosition
        loadFrameProperties()
        buildFrame()
        buildChildrenForData(children)
        setupView(properties: [String: Any]())
    }
    
    init(startWithData data: XMLIndexer, withMaxHeight height: CGFloat, manifestProperties: ManifestProperties, configurations: TractConfigurations, parallelElement: BaseTractElement?) {
        let frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
        super.init(frame: frame)
        self.manifestProperties = manifestProperties
        self.tractConfigurations = configurations
        self.parallelElement = parallelElement
        
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
    
    required init(data: XMLIndexer, startOnY yPosition: CGFloat, parent: BaseTractElement, elementNumber: Int) {
        let frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
        super.init(frame: frame)
        self.parent = parent
        self.elementNumber = elementNumber
        setupElement(data: data, startOnY: yPosition)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Setup
    
    func setupElement(data: XMLIndexer, startOnY yPosition: CGFloat) {
        self.elementFrame.y = yPosition
        
        let contentElements = self.xmlManager.getContentElements(data)
        
        loadElementProperties(contentElements.properties)
        loadFrameProperties()
        buildFrame()
        setupParallelElement()
        buildChildrenForData(contentElements.children)
        setupView(properties: contentElements.properties)
    }
    
    func getPreviousElement() -> BaseTractElement? {
        guard let index = getElementPosition() else {
            return nil
        }
        if index > 0 {
            return self.parent!.elements?[index - 1]
        }
        return nil
    }
    
    func getFollowingElement() -> BaseTractElement? {
        guard let index = getElementPosition() else {
            return nil
        }
        if index < (self.parent?.elements?.count)! - 1 {
            return self.parent?.elements?[index + 1]
        }
        
        return nil
    }
    
    func getElementPosition() -> Int? {
        guard let index = self.parent?.elements?.index(of: self) else {
            return nil
        }
        return index
    }
    
    func buildChildrenForData(_ data: [XMLIndexer]) {
        var currentYPosition: CGFloat = startingYPos()
        var maxYPosition: CGFloat = 0.0
        var elements = [BaseTractElement]()
        var elementNumber: Int = 0
        
        for dictionary in data {
            let element = buildElementForDictionary(dictionary, startOnY: currentYPosition, elementNumber: elementNumber)
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
            
            elementNumber += 1
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
        updateFrameHeight()
        loadStyles()
    }
    
    func loadStyles() { }
    
    func loadFrameProperties() { }
    
    func buildFrame() {
        self.frame = getFrame()
    }
    
    func getFrame() -> CGRect {
        return self.elementFrame.getFrame()
    }
    
    func updateFrameHeight() {
        self.elementFrame.height = self.height
        self.frame = self.elementFrame.getFrame()
    }
    
    func render() -> UIView {
        for element in self.elements! {
            self.addSubview(element.render())
        }
        
        loadParallelElementState()
        TractBindings.addBindings(self)
        return self
    }
    
    // MARK: - Properties
    
    func propertiesKind() -> TractProperties.Type {
        fatalError("propertiesKind() has not been implemented")
    }
    
    func loadElementProperties(_ properties: [String: Any]) {
        self.properties = propertiesKind().init()
        self.properties.setupParentProperties(properties: getParentProperties())
        self.properties.setupDefaultProperties()
        self.properties.load(properties)
    }
    
    func getParentProperties() -> TractProperties {
        if self.parent != nil {
            return self.parent!.properties
        } else {
            return self.manifestProperties
        }
    }
    
    func setupParallelElement() {
        if self.parallelElement != nil || self.parent == nil || self.parent!.parallelElement == nil || self.elementNumber == -1 {
            return
        }
        
        guard let parallelElement = self.parent!.parallelElement!.elements?[self.elementNumber] else {
            return
        }
        
        if type(of: parallelElement) == type(of: self) {
            self.parallelElement = parallelElement
        }
    }
    
    func loadParallelElementState() { }
    
    // MARK: - UI
    
    func parentWidth() -> CGFloat {
        if self.parent != nil {
            return self.parent!.elementFrame.finalWidth()
        } else {
            return getMaxWidth()
        }
    }
    
    func textStyle() -> TractTextContentProperties {
        return self.properties.getTextProperties()
    }
    
    func buttonStyle() -> TractButtonProperties {
        let buttonStyle = TractButtonProperties()
        return buttonStyle
    }
    
    // MARK: View flow management
    
    func notifyViewDidAppearOnTract() {
        self.viewDidAppearOnTract()
        for element in self.elements! {
            element.notifyViewDidAppearOnTract()
        }
    }
    
    func viewDidAppearOnTract() { }
    
    // MARK: Delegate getter & setter
    func setDelegate(_ delegate: BaseTractElementDelegate) {
        self.delegate = delegate
    }
    
    func getDelegate() -> BaseTractElementDelegate? {
        var parent = self.parent
        
        while parent?.parent != nil {
            parent = parent?.parent
        }
        
        return parent!.delegate
    }
}
