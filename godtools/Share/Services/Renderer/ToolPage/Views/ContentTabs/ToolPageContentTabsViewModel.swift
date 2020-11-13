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
    private let language: LanguageModel
    private let translationsFileCache: TranslationsFileCache
    private let mobileContentNodeParser: MobileContentXmlNodeParser
    private let mobileContentAnalytics: MobileContentAnalytics
    private let mobileContentEvents: MobileContentEvents
    private let fontService: FontService
    private let localizationServices: LocalizationServices
    private let followUpsService: FollowUpsService
    private let toolPageColors: ToolPageColorsViewModel
    private let defaultTextNodeTextColor: UIColor?
    private let tabNodes: [ContentTabNode]
    
    let tabLabels: [String]
    let selectedTab: ObservableValue<Int> = ObservableValue(value: 0)
    let tabContent: ObservableValue<ToolPageContentStackViewModel?> = ObservableValue(value: nil)
    
    required init(tabsNode: ContentTabsNode, manifest: MobileContentXmlManifest, language: LanguageModel, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, mobileContentAnalytics: MobileContentAnalytics, mobileContentEvents: MobileContentEvents, fontService: FontService, localizationServices: LocalizationServices, followUpsService: FollowUpsService, toolPageColors: ToolPageColorsViewModel, defaultTextNodeTextColor: UIColor?) {
        
        self.tabsNode = tabsNode
        self.manifest = manifest
        self.language = language
        self.translationsFileCache = translationsFileCache
        self.mobileContentNodeParser = mobileContentNodeParser
        self.mobileContentAnalytics = mobileContentAnalytics
        self.mobileContentEvents = mobileContentEvents
        self.fontService = fontService
        self.localizationServices = localizationServices
        self.followUpsService = followUpsService
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
            mobileContentAnalytics.trackEvents(events: analyticsEventsNode)
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
            manifest: manifest,
            language: language,
            translationsFileCache: translationsFileCache,
            mobileContentNodeParser: mobileContentNodeParser,
            mobileContentAnalytics: mobileContentAnalytics,
            mobileContentEvents: mobileContentEvents,
            fontService: fontService,
            localizationServices: localizationServices,
            followUpsService: followUpsService,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: defaultTextNodeTextColor,
            defaultButtonBorderColor: nil
        )
    }
}
