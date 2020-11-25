//
//  ToolPageContentTabsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageContentTabsViewModel: ToolPageContentTabsViewModelType {
    
    private let tabsNode: ContentTabsNode
    private let diContainer: ToolPageDiContainer
    private let toolPageColors: ToolPageColorsViewModel
    private let defaultTextNodeTextColor: UIColor?
    private let tabNodes: [ContentTabNode]
    
    let tabLabels: [String]
    let selectedTab: ObservableValue<Int> = ObservableValue(value: 0)
    let tabContent: ObservableValue<ToolPageContentStackViewModel?> = ObservableValue(value: nil)
    
    required init(tabsNode: ContentTabsNode, diContainer: ToolPageDiContainer, toolPageColors: ToolPageColorsViewModel, defaultTextNodeTextColor: UIColor?) {
        
        self.tabsNode = tabsNode
        self.diContainer = diContainer
        self.toolPageColors = toolPageColors
        self.defaultTextNodeTextColor = defaultTextNodeTextColor
        self.tabNodes = tabsNode.children as? [ContentTabNode] ?? []
        
        tabLabels = tabNodes.map({$0.contentLabelNode?.textNode?.text ?? ""})
        
        let startingTab: Int = 0
        selectedTab.accept(value: startingTab)
        tabContent.accept(value: getTabContent(tab: startingTab))
    }
    
    func tabTapped(tab: Int) {
        
        selectedTab.setValue(value: tab)
        tabContent.accept(value: getTabContent(tab: tab))
        
        let tabNode: ContentTabNode = tabNodes[tab]
        
        if let analyticsEventsNode = tabNode.analyticsEventsNode {
            diContainer.mobileContentAnalytics.trackEvents(events: analyticsEventsNode)
        }
    }
    
    private func getTabContent(tab: Int) -> ToolPageContentStackViewModel {
        
        let tabNode: ContentTabNode = tabNodes[tab]
        
        let tabNodeChildrenToRender: MobileContentXmlNode = MobileContentXmlNode(xmlElementName: tabNode.xmlElementName)
        
        for childNode in tabNode.children {
            
            let shouldRenderChild: Bool = !(childNode is ContentLabelNode) && !(childNode is AnalyticsEventsNode)
            
            if shouldRenderChild {
                tabNodeChildrenToRender.addChild(childNode: childNode)
            }
        }
        
        return ToolPageContentStackViewModel(
            node: tabNodeChildrenToRender,
            diContainer: diContainer,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: defaultTextNodeTextColor,
            defaultTextNodeTextAlignment: nil,
            defaultButtonBorderColor: nil
        )
    }
}
