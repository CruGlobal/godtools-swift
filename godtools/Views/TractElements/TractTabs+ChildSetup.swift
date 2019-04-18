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

        for item in data.children {
            self.tabs.append(item)
            
            // get content of <tab>
            for node in item.children {
                
                if self.xmlManager.parser.nodeIsLabel(node: node) {
                    if let textNode = self.xmlManager.parser.getTextContentFromElement(node) {
                        self.tabsProperties().options.append(textNode.text)
                    }
                }

                guard let firstChild = node.children.first else { continue }
                let userInfo = TractEventHelper.buildAnalyticsEvents(data: firstChild)
                self.analyticsTabsEvents.append(contentsOf: userInfo)
            }
        }
    }
    
    func buildTabs() {
        let currentYPosition: CGFloat = 28.0
        var maxHeight: CGFloat = currentYPosition
        var elements = [BaseTractElement]()
        var firstElement = true
        var elementIndex: Int = 0
        
        for tabData in self.tabs {
            let element = TractTab(data: tabData, startOnY: currentYPosition, parent: self, elementNumber: elementIndex)
            
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
            
            elementIndex += 1
        }
        
        self.height = maxHeight
        self.elements = elements
    }
}
