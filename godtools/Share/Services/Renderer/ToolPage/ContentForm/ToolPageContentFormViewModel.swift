//
//  ToolPageContentFormViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageContentFormViewModel: NSObject, ToolPageContentFormViewModelType {
    
    private let formNode: ContentFormNode
    private let manifest: MobileContentXmlManifest
    private let translationsFileCache: TranslationsFileCache
    private let mobileContentAnalytics: MobileContentAnalytics
    private let mobileContentEvents: MobileContentEvents
    private let fontService: FontService
    private let toolPageColors: ToolPageColorsViewModel
    private let defaultTextNodeTextColor: UIColor?
    
    let contentViewModel: ToolPageContentStackViewModel
    
    required init(formNode: ContentFormNode, manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, mobileContentAnalytics: MobileContentAnalytics, mobileContentEvents: MobileContentEvents, fontService: FontService, toolPageColors: ToolPageColorsViewModel, defaultTextNodeTextColor: UIColor?) {
        
        self.formNode = formNode
        self.manifest = manifest
        self.translationsFileCache = translationsFileCache
        self.mobileContentAnalytics = mobileContentAnalytics
        self.mobileContentEvents = mobileContentEvents
        self.fontService = fontService
        self.toolPageColors = toolPageColors
        self.defaultTextNodeTextColor = defaultTextNodeTextColor
        
        contentViewModel = ToolPageContentStackViewModel(
            node: formNode,
            manifest: manifest,
            translationsFileCache: translationsFileCache,
            mobileContentAnalytics: mobileContentAnalytics,
            mobileContentEvents: mobileContentEvents,
            fontService: fontService,
            itemSpacing: 15,
            scrollIsEnabled: false,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: defaultTextNodeTextColor
        )
        
        super.init()
        
        addObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    private func addObservers() {
        
        mobileContentEvents.eventButtonTappedSignal.addObserver(self) { [weak self] (buttonEvent: ButtonEvent) in
            if buttonEvent.event == "followup:send" {
                self?.sendFollowUps()
            }
        }
    }
    
    private func removeObservers() {
        mobileContentEvents.eventButtonTappedSignal.removeObserver(self)
    }
    
    private func sendFollowUps() {
        print("\n SEND FOLLOW UPS")
    }
}
