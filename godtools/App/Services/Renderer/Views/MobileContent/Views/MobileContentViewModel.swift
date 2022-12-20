//
//  MobileContentViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentViewModel: NSObject {
    
    private let mobileContentAnalytics: MobileContentAnalytics
    
    let baseModel: BaseModel?
    let baseModels: [BaseModel]
    let renderedPageContext: MobileContentRenderedPageContext
    
    init(baseModel: BaseModel?, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.baseModel = baseModel
        
        if let baseModel = baseModel {
            self.baseModels = [baseModel]
        }
        else {
            self.baseModels = Array()
        }
        
        self.renderedPageContext = renderedPageContext
        self.mobileContentAnalytics = mobileContentAnalytics
                
        super.init()
    }
    
    init(baseModels: [BaseModel], renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.baseModel = baseModels.first
        self.baseModels = baseModels
        
        self.renderedPageContext = renderedPageContext
        self.mobileContentAnalytics = mobileContentAnalytics
        
        super.init()
    }
    
    var rendererState: State {
        return renderedPageContext.rendererState
    }
    
    var languageTextAlignment: NSTextAlignment {
        return renderedPageContext.language.languageDirection == .leftToRight ? .left : .right
    }
    
    func viewDidAppear(analyticsEvents: [MobileContentAnalyticsEvent]) {
        
        for event in analyticsEvents {
            
            let trigger: AnalyticsEvent.Trigger = event.analyticsEvent.trigger

            if trigger == .visible {
                event.trigger()
            }
        }
    }
    
    func viewDidDisappear(analyticsEvents: [MobileContentAnalyticsEvent]) {
        
        for event in analyticsEvents {
            
            let trigger: AnalyticsEvent.Trigger = event.analyticsEvent.trigger
            
            if trigger == .visible {
                event.cancel()
            }
        }
    }
}

// MARK: - Clickable

extension MobileContentViewModel {
    
    func viewTapped() {
                
        mobileContentAnalytics.trackEvents(
            events: getClickableAnalyticsEvents(),
            renderedPageContext: renderedPageContext
        )
    }
    
    func getIsClickable() -> Bool {
        
        guard let clickableModel = baseModel as? Clickable else {
            return false
        }
        
        return clickableModel.isClickable
    }
    
    func getClickableAnalyticsEvents() -> [AnalyticsEvent] {
        
        guard let clickableModel = baseModel as? Clickable, clickableModel.isClickable,
              let modelHasAnalyticsEvents = clickableModel as? HasAnalyticsEvents else {
            
            return Array()
        }
        
        return modelHasAnalyticsEvents.getAnalyticsEvents(type: .clicked)
    }
    
    func getClickableEvents() -> [EventId] {
        
        guard let clickableModel = baseModel as? Clickable, clickableModel.isClickable else {
            return Array()
        }
        
        return clickableModel.events
    }
    
    func getClickableUrl() -> URL? {
        
        guard let clickableModel = baseModel as? Clickable, clickableModel.isClickable else {
            return nil
        }
        
        return clickableModel.url
    }
}