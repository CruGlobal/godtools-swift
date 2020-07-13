//
//  TractTabs.swift
//  godtools
//
//  Created by Devserker on 5/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

class TractTabs: BaseTractElement {
    
    // MARK: Positions constants
    
    static let xMarginConstant: CGFloat = 16.0
    static let yMarginConstant: CGFloat = 16.0
    
    // MARK - Setup
    
    var segmentedControl = UISegmentedControl()
    var tabs = [XMLIndexer]()
    var analyticsTabsEvents: [TractAnalyticEvent] = []
    
    override func propertiesKind() -> TractProperties.Type {
        return TractTabsProperties.self
    }
    
    override func setupElement(data: XMLIndexer, startOnY yPosition: CGFloat) {
        self.elementFrame.y = yPosition
        
        let contentElements = self.xmlManager.getContentElements(data)
        
        loadElementProperties(contentElements.properties)
        loadFrameProperties()
        
        getTabsLabels(data: data)
        buildTabs()
        setupView(properties: contentElements.properties)
    }
    
    override func setupView(properties: [String: Any]) {
        super.setupView(properties: properties)
        setupSegmentedControl()
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.width = self.parentWidth()
        self.elementFrame.height = self.height
        self.elementFrame.yMarginTop = TractTabs.yMarginConstant
        self.elementFrame.yMarginBottom = TractTabs.yMarginConstant
        self.elementFrame.xMargin = 0.0
    }
    
    // MARK - Helpers
    
    func tabsProperties() -> TractTabsProperties {
        return self.properties as! TractTabsProperties
    }

}

// MARK: - Child Setup

extension TractTabs {
    
    func getTabsLabels(data: XMLIndexer) {

        // get tabs
        for tab in data.children {
            
            // get content of <tab>
            for node in tab.children {
                
                if self.xmlManager.parser.nodeIsLabel(node: node) {
                    if let textNode = self.xmlManager.parser.getTextContentFromElement(node) {
                        self.tabsProperties().options.append(textNode.text)
                    }
                }

                guard let firstChild = node.children.first else { continue }
                let userInfo = TractEventHelper.buildAnalyticsEvents(data: firstChild)
                self.analyticsTabsEvents.append(contentsOf: userInfo)
            }
            
            // find and remove "label", it is obsolete in view hierarchy. do it with "copy at hand" (parse string again) to keep original xml intact for reload
            let t = SWXMLHash.parse(tab.description).children.first!    // SWXMLHash has default root object we need to skip
            remove(inNode: t, text: "label")
            self.tabs.append(t)
        }
    }
    
    func remove(inNode node: XMLIndexer, text: String) {

        node.element?.children.removeAll(where: { (content) -> Bool in
            guard let elem = content as? XMLElement else { return false }
            return elem.name.contains(text)
        })
    }
    
    func buildTabs() {
        let currentYPosition: CGFloat = 28.0
        var maxHeight: CGFloat = currentYPosition
        var elements = [BaseTractElement]()
        var elementIndex: Int = 0
        
        for tabData in self.tabs {
            
            let element = TractTab(data: tabData, startOnY: currentYPosition, parent: self, elementNumber: elementIndex, dependencyContainer: dependencyContainer, isPrimaryRightToLeft: isPrimaryRightToLeft)
            element.isHidden = elementIndex != 0
            
            if element.height > maxHeight {
                maxHeight = element.height
            }
            elements.append(element)
            
            elementIndex += 1
        }
        
        self.height = maxHeight
        self.elements = elements
    }
}

// MARK: - UI

extension TractTabs {
    
    func setupSegmentedControl() {
        let properties = tabsProperties()
        properties.analyticsTabsUserInfo = self.analyticsTabsEvents
        
        let width = self.elementFrame.finalWidth()
        let height: CGFloat = 28.0
        let frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        
        self.segmentedControl = UISegmentedControl(frame: frame)
        for i in 0..<properties.options.count {
            self.segmentedControl.insertSegment(withTitle: properties.options[i], at: i, animated: true)
        }
        
        let originalAttributes = segmentedControl.titleTextAttributes(for: .normal)
        if let originalFont = originalAttributes?[NSAttributedString.Key.font] as? UIFont {
            let font = originalFont.transformToAppropriateFontByLanguage(self.tractConfigurations!.language!, textScale: 1.0)
            self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        }
        
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentedControl.tintColor = self.manifestProperties.primaryColor
        self.segmentedControl.addTarget(self, action: #selector(newOptionSelected), for: .valueChanged)
        
        self.addSubview(self.segmentedControl)
    }
    
    @objc func newOptionSelected() {
        for element in self.elements! {
            element.isHidden = true
        }
        let properties = tabsProperties()
        self.elements![self.segmentedControl.selectedSegmentIndex].isHidden = false
        
        if self.segmentedControl.selectedSegmentIndex == 1 {
            for analyticEvent in properties.analyticsTabsUserInfo {
                let userInfo = TractAnalyticEvent.convertToDictionary(from: analyticEvent)
                sendAnalyticsEvents(userInfo: userInfo)
            }
        }
    }
    
    func sendAnalyticsEvents(userInfo: [String: Any]) {
        NotificationCenter.default.post(name: .actionTrackNotification,
                                        object: nil,
                                        userInfo: userInfo)
    }
    
    func selectTab(_ withIndex: Int) {
        segmentedControl.selectedSegmentIndex = withIndex
        newOptionSelected()
    }
}
