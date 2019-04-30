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
            
            // find and remove "label", it is obsolete in view hierarchy
            remove(inNode: tab, text: "label")
            self.tabs.append(tab)
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
            let element = TractTab(data: tabData, startOnY: currentYPosition, parent: self, elementNumber: elementIndex)
            
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
