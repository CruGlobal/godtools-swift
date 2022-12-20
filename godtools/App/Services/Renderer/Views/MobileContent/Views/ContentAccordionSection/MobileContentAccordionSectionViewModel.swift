//
//  MobileContentAccordionSectionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentAccordionSectionViewModel: MobileContentViewModel {
    
    private let sectionModel: Accordion.Section
    private let mobileContentAnalytics: MobileContentAnalytics
    private let analyticsEventsObjects: [MobileContentAnalyticsEvent]
    
    init(sectionModel: Accordion.Section, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.sectionModel = sectionModel
        self.mobileContentAnalytics = mobileContentAnalytics
        
        self.analyticsEventsObjects = MobileContentAnalyticsEvent.initAnalyticsEvents(
            analyticsEvents: sectionModel.getAnalyticsEvents(type: .visible),
            mobileContentAnalytics: mobileContentAnalytics,
            renderedPageContext: renderedPageContext
        )
        
        super.init(baseModel: sectionModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
}

// MARK: - Inputs

extension MobileContentAccordionSectionViewModel {
    
    func sectionOpened() {
        super.viewDidAppear(analyticsEvents: analyticsEventsObjects)
    }
    
    func sectionClosed() {
        super.viewDidDisappear(analyticsEvents: analyticsEventsObjects)
    }
}
