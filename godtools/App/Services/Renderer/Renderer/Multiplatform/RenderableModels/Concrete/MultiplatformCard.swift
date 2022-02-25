//
//  MultiplatformCard.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MultiplatformCard {
    
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
    
    var backgroundImageAlignment: Gravity? {
        return card.backgroundImageGravity
    }
    
    var backgroundImageScale: ImageScaleType {
        return card.backgroundImageScaleType
    }
    
    var dismissListeners: [EventId] {
        return Array(card.dismissListeners)
    }
    
    var listeners: [EventId] {
        return Array(card.listeners)
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
    
    func getTitleColor() -> UIColor? {
        
        if let labelTextColor = card.label?.textColor {
            return labelTextColor
        }
        return nil
    }
    
    func getAnalyticsEvents() -> [AnalyticsEvent] {
        return card.analyticsEvents
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformCard: MobileContentRenderableModel {
        
    func getRenderableChildModels() -> [Any] {
        
        return card.content
    }
}
