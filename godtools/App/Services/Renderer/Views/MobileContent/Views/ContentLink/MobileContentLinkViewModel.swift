//
//  MobileContentLinkViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentLinkViewModel: MobileContentLinkViewModelType {
    
    private let linkModel: Link
    private let rendererPageModel: MobileContentRendererPageModel
    private let mobileContentAnalytics: MobileContentAnalytics
    private let fontService: FontService
    private let fontSize: CGFloat = 18
    private let fontWeight: UIFont.Weight = .regular
    
    let titleColor: UIColor
    
    required init(linkModel: Link, rendererPageModel: MobileContentRendererPageModel, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService) {
        
        self.linkModel = linkModel
        self.rendererPageModel = rendererPageModel
        self.mobileContentAnalytics = mobileContentAnalytics
        self.fontService = fontService
        self.titleColor = linkModel.textColor
    }
    
    var backgroundColor: UIColor {
        return .clear
    }
    
    var font: UIFont {
        return fontService.getFont(size: fontSize, weight: fontWeight)
    }
    
    var title: String? {
        return linkModel.text?.text
    }
    
    var linkEvents: [MultiplatformEventId] {
        // TODO: Remove MultiplatformEventId. ~Levi
        return linkModel.events.map({MultiplatformEventId(eventId: $0)})
    }
    
    var rendererState: State {
        return rendererPageModel.rendererState
    }
    
    func linkTapped() {
        
        // TODO: Remove MultiplatformAnalyticsEvent. ~Levi
        
        let events: [AnalyticsEventModelType] = linkModel.analyticsEvents.map({MultiplatformAnalyticsEvent(analyticsEvent: $0)})
        
        mobileContentAnalytics.trackEvents(events: events, rendererPageModel: rendererPageModel)
    }
}
