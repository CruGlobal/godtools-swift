//
//  MobileContentClickableViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/8/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentClickableViewModel: MobileContentViewModel {
    
    private let mobileContentAnalytics: MobileContentAnalytics
    
    init(baseModel: BaseModel?, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics) {

        self.mobileContentAnalytics = mobileContentAnalytics
                
        super.init(baseModel: baseModel, renderedPageContext: renderedPageContext)
    }
    
    init(baseModels: [BaseModel], renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.mobileContentAnalytics = mobileContentAnalytics
        
        super.init(baseModels: baseModels, renderedPageContext: renderedPageContext)
    }
    
    func getEvents() -> [EventId] {
        
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
    
    func viewTapped() {
                
        if let clickableModel = baseModel as? Clickable, clickableModel.isClickable,
           let modelHasAnalyticsEvents = clickableModel as? HasAnalyticsEvents {
            
            let clickableAnalyticsEvents: [AnalyticsEvent] = modelHasAnalyticsEvents.getAnalyticsEvents(type: .clicked)
            
            mobileContentAnalytics.trackEvents(
                events: clickableAnalyticsEvents,
                renderedPageContext: renderedPageContext
            )
        }
    }
}
