//
//  MultiplatformTractPage.swift
//  godtools
//
//  Created by Levi Eggert on 7/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MultiplatformTractPage: PageModelType {
    
    private let tractPage: TractPage
    
    let uuid: String = UUID().uuidString
    
    required init(tractPage: TractPage) {
        
        self.tractPage = tractPage
    }
    
    var id: String {
        return tractPage.id
    }
    
    var backgroundImage: String? {
        return tractPage.backgroundImage?.name
    }
    
    var backgroundImageAlignment: Gravity? {
        return tractPage.backgroundImageGravity
    }
    
    var backgroundImageScale: ImageScaleType {
        return tractPage.backgroundImageScaleType
    }
    
    var listeners: [MultiplatformEventId] {
        return tractPage.listeners.map({MultiplatformEventId(eventId: $0)})
    }
    
    var textScale: MobileContentTextScale {
        return MobileContentTextScale(doubleValue: tractPage.textScale)
    }
    
    var isHidden: Bool {
        // NOTE: I believe this concept hasn't been introduced to TractPage, but is part of LessonPage. ~Levi
        return false
    }
    
    var hero: Hero? {
        return tractPage.hero
    }
    
    var callToAction: CallToAction? {
        return tractPage.callToAction
    }
    
    func getBackgroundColor() -> UIColor? {
        return tractPage.backgroundColor
    }
    
    func getCardTextColor() -> UIColor? {
        return tractPage.cardTextColor
    }
    
    func getPrimaryColor() -> UIColor? {
        return tractPage.primaryColor
    }
    
    func getPrimaryTextColor() -> UIColor? {
        return tractPage.primaryTextColor
    }
    
    func getTextColor() -> UIColor? {
        return tractPage.textColor
    }
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType] {
        return tractPage.getAnalyticsEvents(type: .visible).map({MultiplatformAnalyticsEvent(analyticsEvent: $0)})
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformTractPage {
    
    var restrictTo: String? {
        return nil
    }
    
    var version: String? {
        return nil
    }
    
    var modelContentIsRenderable: Bool {
        return true
    }
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        
        var childModels: [MobileContentRenderableModel] = Array()
        
        if let header = tractPage.header {
            childModels.append(header)
        }
        
        if let hero = tractPage.hero {
            childModels.append(hero)
        }
        
        if tractPage.cards.count > 0 {
            childModels.append(MultiplatformCards(cards: tractPage.cards))
        }
        
        childModels.append(tractPage.callToAction)
        
        childModels.append(MultiplatformModals(modals: tractPage.modals))
        
        return childModels
    }
}
