//
//  MultiplatformCardCollectionPage.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformCardCollectionPage: PageModelType {
    
    private let cardCollectionPage: CardCollectionPage
    
    let uuid: String = UUID().uuidString
    
    required init(cardCollectionPage: CardCollectionPage) {
        
        self.cardCollectionPage = cardCollectionPage
    }
    
    var backgroundImage: String? {
        return cardCollectionPage.backgroundImage?.name
    }
    
    var backgroundImageAlignment: MobileContentImageAlignmentType {
        return MultiplatformImageAlignment(imageGravity: cardCollectionPage.backgroundImageGravity)
    }
    
    var backgroundImageScale: MobileContentBackgroundImageScale {
        switch cardCollectionPage.backgroundImageScaleType {
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
        return cardCollectionPage.listeners.map({MultiplatformEventId(eventId: $0)})
    }
    
    var textScale: MobileContentTextScale {
        return MobileContentTextScale(doubleValue: cardCollectionPage.textScale)
    }
    
    var isHidden: Bool {
        return cardCollectionPage.isHidden
    }
    
    var hero: HeroModelType? {
        return nil
    }
    
    var callToAction: CallToAction? {
        return nil
    }
    
    func getBackgroundColor() -> MobileContentColor? {
        return MobileContentColor(color: cardCollectionPage.backgroundColor)
    }
    
    func getCardTextColor() -> MobileContentColor? {
        return nil
    }
    
    func getPrimaryColor() -> MobileContentColor? {
        return MobileContentColor(color: cardCollectionPage.primaryColor)
    }
    
    func getPrimaryTextColor() -> MobileContentColor? {
        return MobileContentColor(color: cardCollectionPage.primaryTextColor)
    }
    
    func getTextColor() -> MobileContentColor? {
        return MobileContentColor(color: cardCollectionPage.textColor)
    }
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType] {
        return cardCollectionPage.getAnalyticsEvents(type: .visible).map({MultiplatformAnalyticsEvent(analyticsEvent: $0)})
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformCardCollectionPage {
    
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
        
        return cardCollectionPage.cards
    }
}
