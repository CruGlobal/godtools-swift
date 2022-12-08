//
//  ClickableMobileContentViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/30/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

protocol ClickableMobileContentViewModel {
        
    func getClickableUrl() -> URL?
}

extension ClickableMobileContentViewModel {
    
    func getClickableAnalyticsEvents(model: Clickable) -> [AnalyticsEvent] {
        
        guard let modelHasAnalyticsEvents = model as? HasAnalyticsEvents else {
            return Array()
        }
        
        return modelHasAnalyticsEvents.getAnalyticsEvents(type: .clicked)
    }
    
    func getClickableUrl(model: Clickable) -> URL? {
        return model.url
    }
    
    func trackClickableEvents(model: Clickable, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics) {
        
        mobileContentAnalytics.trackEvents(
            events: getClickableAnalyticsEvents(model: model),
            renderedPageContext: renderedPageContext
        )
    }
}
