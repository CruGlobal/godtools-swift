//
//  TractTabs+ChildSetup.swift
//  godtools
//
//  Created by Pablo Marti on 6/13/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

extension TractTabs {
    
    func getTabsLabels(data: XMLIndexer) {
        var position = 0
        for item in data.children {
            self.tabs.append([XMLIndexer]())
            
            for node in item.children {
                
                let userInfo = TractEventHelper.buildAnalyticsEvents(data: node)
                //if userInfo.count > 0 {
                    self.analyticsTabsEvents.append(contentsOf: userInfo)
                //}
                
                if self.xmlManager.parser.nodeIsLabel(node: node) {
                    if let textNode = self.xmlManager.parser.getTextContentFromElement(node) {
                        self.tabsProperties().options.append(textNode.text)
                    }
                } else {
                    self.tabs[position].append(node)
                }
            }
            
            position += 1
        }
    }
    
    func buildTabs() {
        let currentYPosition: CGFloat = 28.0
        var maxHeight: CGFloat = currentYPosition
        var elements = [BaseTractElement]()
        var firstElement = true
        
        for tabData in self.tabs {
            let element = TractTab(children: tabData, startOnY: currentYPosition, parent: self)
            
            if firstElement {
                element.isHidden = false
                firstElement = false
            } else {
                element.isHidden = true
            }
            
            if element.height > maxHeight {
                maxHeight = element.height
            }
            elements.append(element)
        }
        
        self.height = maxHeight
        self.elements = elements
    }
    
}
