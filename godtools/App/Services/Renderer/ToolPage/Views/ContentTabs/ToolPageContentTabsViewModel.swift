//
//  ToolPageContentTabsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageContentTabsViewModel: NSObject, ToolPageContentTabsViewModelType {
    
    private let tabsNode: ContentTabsNode
    private let diContainer: ToolPageDiContainer
    private let toolPageColors: ToolPageColors
    private let defaultTextNodeTextColor: UIColor?
    private let tabNodes: [ContentTabNode]
    
    let tabLabels: [String]
    let selectedTab: ObservableValue<Int> = ObservableValue(value: 0)
    let tabContent: ObservableValue<MobileContentStackView?> = ObservableValue(value: nil)
    
    required init(tabsNode: ContentTabsNode, diContainer: ToolPageDiContainer, toolPageColors: ToolPageColors, defaultTextNodeTextColor: UIColor?) {
        
        self.tabsNode = tabsNode
        self.diContainer = diContainer
        self.toolPageColors = toolPageColors
        self.defaultTextNodeTextColor = defaultTextNodeTextColor
        self.tabNodes = tabsNode.children as? [ContentTabNode] ?? []
        
        tabLabels = tabNodes.map({$0.contentLabelNode?.textNode?.text ?? ""})
        
        super.init()
        
        addEventListeners()
        
        let startingTab: Int = 0
        selectedTab.accept(value: startingTab)
        tabContent.accept(value: getTabContent(tab: startingTab))
    }
    
    deinit {
        removeEventListeners()
    }
    
    private func addEventListeners() {
        
        diContainer.mobileContentEvents.eventImageTappedSignal.addObserver(self) { [weak self] (imageEvent: ImageEvent) in
            
            guard let viewModel = self else {
                return
            }
                        
            for tabIndex in 0 ..< viewModel.tabNodes.count {
                let tabNode: ContentTabNode = viewModel.tabNodes[tabIndex]
                if tabNode.listeners.contains(imageEvent.event) {
                    self?.selectedTab.accept(value: tabIndex)
                    self?.tabTapped(tab: tabIndex)
                    break
                }
            }
        }
    }
    
    private func removeEventListeners() {
        diContainer.mobileContentEvents.eventImageTappedSignal.removeObserver(self)
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return diContainer.languageDirectionSemanticContentAttribute
    }
    
    func tabTapped(tab: Int) {
        
        selectedTab.setValue(value: tab)
        tabContent.accept(value: getTabContent(tab: tab))
        
        let tabNode: ContentTabNode = tabNodes[tab]
        
        if let analyticsEventsNode = tabNode.analyticsEventsNode {
            diContainer.mobileContentAnalytics.trackEvents(events: analyticsEventsNode)
        }
    }
    
    private func getTabContent(tab: Int) -> MobileContentStackView? {
        
        let tabNode: ContentTabNode = tabNodes[tab]
        
        let contentStackRenderer = ToolPageContentStackRenderer(
            rootContentStackRenderer: nil,
            diContainer: diContainer,
            node: tabNode,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: defaultTextNodeTextColor,
            defaultTextNodeTextAlignment: nil,
            defaultButtonBorderColor: nil
        )
        
        return contentStackRenderer.render() as? MobileContentStackView
    }
}
