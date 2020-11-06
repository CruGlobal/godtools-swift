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
    private let manifest: MobileContentXmlManifest
    private let translationsFileCache: TranslationsFileCache
    private let mobileContentEvents: MobileContentEvents
    private let fontService: FontService
    private let toolPageColors: ToolPageColorsViewModel
    private let defaultTextNodeTextColor: UIColor?
    private let tabNodes: [ContentTabNode]
    
    let tabLabels: [String]
    let selectedTab: ObservableValue<Int> = ObservableValue(value: 0)
    let tabContent: ObservableValue<ToolPageContentStackViewModel?> = ObservableValue(value: nil)
    
    required init(tabsNode: ContentTabsNode, manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, mobileContentEvents: MobileContentEvents, fontService: FontService, toolPageColors: ToolPageColorsViewModel, defaultTextNodeTextColor: UIColor?) {
        
        self.tabsNode = tabsNode
        self.manifest = manifest
        self.translationsFileCache = translationsFileCache
        self.mobileContentEvents = mobileContentEvents
        self.fontService = fontService
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
    }
    
    private func getTabContent(tab: Int) -> ToolPageContentStackViewModel {
        
        let tabNode: ContentTabNode = tabNodes[tab]
        
        return ToolPageContentStackViewModel(
            node: tabNode,
            manifest: manifest,
            translationsFileCache: translationsFileCache,
            mobileContentEvents: mobileContentEvents,
            fontService: fontService,
            itemSpacing: 10,
            scrollIsEnabled: false,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: defaultTextNodeTextColor
        )
    }
}
