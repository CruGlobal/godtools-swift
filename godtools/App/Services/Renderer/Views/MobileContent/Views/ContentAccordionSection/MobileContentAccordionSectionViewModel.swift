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
    private let renderedPageContext: MobileContentRenderedPageContext
    private let mobileContentAnalytics: MobileContentAnalytics
    private let analyticsEventsObjects: [MobileContentAnalyticsEvent]
    
    init(sectionModel: Accordion.Section, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.sectionModel = sectionModel
        self.renderedPageContext = renderedPageContext
        self.mobileContentAnalytics = mobileContentAnalytics
        
        self.analyticsEventsObjects = MobileContentAnalyticsEvent.initAnalyticsEvents(
            analyticsEvents: sectionModel.getAnalyticsEvents(type: .visible),
            mobileContentAnalytics: mobileContentAnalytics,
            renderedPageContext: renderedPageContext
        )
        
        super.init(baseModel: sectionModel)
    }
}

// MARK: - MobileContentViewModelType

extension MobileContentAccordionSectionViewModel: MobileContentViewModelType {
    
    var language: LanguageModel {
        return renderedPageContext.language
    }
    
    var analyticsEvents: [MobileContentAnalyticsEvent] {
        return analyticsEventsObjects
    }
}

// MARK: - Inputs

extension MobileContentAccordionSectionViewModel {
    
    func sectionOpened() {
        mobileContentDidAppear()
    }
    
    func sectionClosed() {
        mobileContentDidDisappear()
    }
}
