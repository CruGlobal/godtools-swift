//
//  MobileContentTabsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentTabsViewModel: NSObject, MobileContentTabsViewModelType {
    
    private let tabsNode: ContentTabsNode
    private let pageModel: MobileContentRendererPageModel
    private let tabNodes: [ContentTabNode]
    
    let tabLabels: [String]
    let selectedTab: ObservableValue<Int> = ObservableValue(value: 0)
    let tabContent: ObservableValue<ToolPageContentStackContainerViewModel?> = ObservableValue(value: nil)
    
    required init(tabsNode: ContentTabsNode, pageModel: MobileContentRendererPageModel) {
        
        self.tabsNode = tabsNode
        self.pageModel = pageModel
        self.tabNodes = tabsNode.children as? [ContentTabNode] ?? []
        
        tabLabels = tabNodes.map({$0.contentLabelNode?.textNode?.text ?? ""})
        
        super.init()
        
        addEventListeners()
        
        let startingTab: Int = 0
        selectedTab.accept(value: startingTab)
        //tabContent.accept(value: getTabContent(tab: startingTab))
    }
    
    deinit {
        removeEventListeners()
    }
    
    private func addEventListeners() {
        
        /*
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
        }*/
    }
    
    private func removeEventListeners() {
        //diContainer.mobileContentEvents.eventImageTappedSignal.removeObserver(self)
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return pageModel.languageDirectionSemanticContentAttribute
    }
    
    func tabTapped(tab: Int) {
        
        selectedTab.setValue(value: tab)
        //tabContent.accept(value: getTabContent(tab: tab))
        
        let tabNode: ContentTabNode = tabNodes[tab]
        
        /*
        if let analyticsEventsNode = tabNode.analyticsEventsNode {
            diContainer.mobileContentAnalytics.trackEvents(events: analyticsEventsNode)
        }*/
    }
    
    /*
    private func getTabContent(tab: Int) -> ToolPageContentStackContainerViewModel {
        
        let tabNode: ContentTabNode = tabNodes[tab]
        
        let tabNodeChildrenToRender: MobileContentXmlNode = MobileContentXmlNode(xmlElement: tabNode.xmlElement)
        
        for childNode in tabNode.children {
            
            let shouldRenderChild: Bool = !(childNode is ContentLabelNode) && !(childNode is AnalyticsEventsNode)
            
            if shouldRenderChild {
                tabNodeChildrenToRender.addChild(childNode: childNode)
            }
        }
        
        return ToolPageContentStackContainerViewModel(
            node: tabNodeChildrenToRender,
            diContainer: diContainer,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: defaultTextNodeTextColor,
            defaultTextNodeTextAlignment: nil,
            defaultButtonBorderColor: nil
        )
    }*/
}
