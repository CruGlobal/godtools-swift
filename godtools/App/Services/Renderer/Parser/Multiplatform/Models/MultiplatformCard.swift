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
    
    private let card: Card
    
    let numberOfVisibleCards: Int
    
    required init(card: Card, numberOfVisibleCards: Int) {
        
        self.card = card
        self.numberOfVisibleCards = numberOfVisibleCards
    }
    
    var backgroundImage: String? {
        let fileName: String? = card.backgroundImage?.name
        return fileName
    }
    
    var backgroundImageAlignments: [MobileContentBackgroundImageAlignment] {
        return [] // TODO: Set this. ~Levi
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
    
    var dismissListeners: [String] {
        return card.dismissListeners.map({$0.description()})
    }
    
    var listeners: [String] {
        return card.listeners.map({$0.description()})
    }
    
    var isHidden: Bool {
        return card.isHidden
    }
    
    var text: String? {
        return card.label?.text
    }
    
    var hasTrainingTip: Bool {
        return card.tips.count > 0
    }
    
    var cardPositionInVisibleCards: Int {
        return card.visiblePosition?.intValue ?? 0
    }
    
    func getTextColor() -> MobileContentColor? {
        return MobileContentColor(color: card.textColor)
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
