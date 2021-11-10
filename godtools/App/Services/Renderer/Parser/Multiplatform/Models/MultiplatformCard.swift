//
//  MultiplatformCard.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformCard: CardModelType {
    
    private let card: TractPage.Card
    
    let numberOfVisibleCards: Int
    
    required init(card: TractPage.Card, numberOfVisibleCards: Int) {
        
        self.card = card
        self.numberOfVisibleCards = numberOfVisibleCards
    }
    
    var backgroundImage: String? {
        let fileName: String? = card.backgroundImage?.name
        return fileName
    }
    
    var backgroundImageAlignment: MobileContentImageAlignmentType {
        return MultiplatformImageAlignment(imageGravity: card.backgroundImageGravity)
    }
    
    var backgroundImageScale: MobileContentBackgroundImageScale {
        
        switch card.backgroundImageScaleType {
        case .fit:
            return .fit
        case .fill:
            return .fill
        case .fillX:
            return .fillHorizontally
        case .fillY:
            return .fillVertically
        default:
            assertionFailure("Found unsupported type, returning fill.  Ensure case is supported.")
            return .fill
        }
    }
    
    var dismissListeners: [MultiplatformEventId] {
        return card.dismissListeners.map({MultiplatformEventId(eventId: $0)})
    }
    
    var listeners: [MultiplatformEventId] {
        return card.listeners.map({MultiplatformEventId(eventId: $0)})
    }
    
    var isHidden: Bool {
        return card.isHidden
    }
    
    var title: String? {
        return card.label?.text
    }
    
    var hasTrainingTip: Bool {
        return card.tips.count > 0
    }
    
    var cardPositionInVisibleCards: Int {
        return card.visiblePosition?.intValue ?? 0
    }
    
    func getTitleColor() -> MobileContentColor? {
        
        if let labelTextColor = card.label?.textColor {
            return MobileContentColor(color: labelTextColor)
        }
        return nil
    }
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType] {
        return card.analyticsEvents.map({MultiplatformAnalyticsEvent(analyticsEvent: $0)})
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformCard {
    
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

        addContentToChildModels(childModels: &childModels, content: card.content)
                
        return childModels
    }
}

// MARK: - MobileContentRenderableModelContainer

extension MultiplatformCard: MobileContentRenderableModelContainer {
    
    var buttonColor: MobileContentColor? {
        return nil
    }
    
    var buttonStyle: MobileContentButtonStyle? {
        return nil
    }
    
    var primaryColor: MobileContentColor? {
        return nil
    }
    
    var primaryTextColor: MobileContentColor? {
        return nil
    }
    
    var textAlignment: MobileContentTextAlignment? {
        return nil
    }
    
    var textColor: MobileContentColor? {
        return nil
    }
}
