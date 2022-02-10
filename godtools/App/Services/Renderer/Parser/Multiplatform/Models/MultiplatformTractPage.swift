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
    
    var backgroundImage: String? {
        return tractPage.backgroundImage?.name
    }
    
    var backgroundImageAlignment: MobileContentImageAlignmentType {
        return MultiplatformImageAlignment(imageGravity: tractPage.backgroundImageGravity)
    }
    
    var backgroundImageScale: MobileContentBackgroundImageScale {
        switch tractPage.backgroundImageScaleType {
        case .fill:
            return .fill
        case .fit:
            return .fit
        case .fillX:
            return .fillHorizontally
        case .fillY:
            return .fillVertically
        default:
            assertionFailure("Found unsupported type, returning fill.  Ensure case is supported.")
            return .fill
        }
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
    
    var hero: HeroModelType? {
        guard let hero = tractPage.hero else {
            return nil
        }
        return MultiplatformHero(hero: hero)
    }
    
    var callToAction: CallToAction? {
        return tractPage.callToAction
    }
    
    func getBackgroundColor() -> MobileContentColor? {
        return MobileContentColor(color: tractPage.backgroundColor)
    }
    
    func getCardTextColor() -> MobileContentColor? {
        return MobileContentColor(color: tractPage.cardTextColor)
    }
    
    func getPrimaryColor() -> MobileContentColor? {
        return MobileContentColor(color: tractPage.primaryColor)
    }
    
    func getPrimaryTextColor() -> MobileContentColor? {
        return MobileContentColor(color: tractPage.primaryTextColor)
    }
    
    func getTextColor() -> MobileContentColor? {
        return MobileContentColor(color: tractPage.textColor)
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
            childModels.append(MultiplatformHeader(header: header))
        }
        
        if let hero = tractPage.hero {
            childModels.append(MultiplatformHero(hero: hero))
        }
        
        if tractPage.cards.count > 0 {
            childModels.append(MultiplatformCards(cards: tractPage.cards))
        }
        
        childModels.append(MultiplatformCallToAction(callToAction: tractPage.callToAction))
        
        childModels.append(MultiplatformModals(modals: tractPage.modals))
        
        return childModels
    }
}
