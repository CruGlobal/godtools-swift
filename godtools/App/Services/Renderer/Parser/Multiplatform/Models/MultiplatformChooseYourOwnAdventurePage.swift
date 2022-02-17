//
//  MultiplatformChooseYourOwnAdventurePage.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser
import UIKit

class MultiplatformChooseYourOwnAdventurePage: PageModelType {
    
    private let page: Page
    
    let uuid: String = UUID().uuidString
    
    required init(page: Page) {
        
        self.page = page
    }
    
    var id: String {
        return page.id
    }
    
    var backgroundImage: String? {
        return page.backgroundImage?.name
    }
    
    var backgroundImageAlignment: MobileContentImageAlignmentType {
        return MultiplatformImageAlignment(imageGravity: page.backgroundImageGravity)
    }
    
    var backgroundImageScale: MobileContentBackgroundImageScale {
        switch page.backgroundImageScaleType {
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
        return page.listeners.map({MultiplatformEventId(eventId: $0)})
    }
    
    var textScale: MobileContentTextScale {
        return MobileContentTextScale(doubleValue: page.textScale)
    }
    
    var isHidden: Bool {
        return page.isHidden
    }
    
    var hero: Hero? {
        return nil
    }
    
    var callToAction: CallToAction? {
        return nil
    }
    
    func getBackgroundColor() -> UIColor? {
        return page.backgroundColor
    }
    
    func getCardTextColor() -> UIColor? {
        return nil
    }
    
    func getPrimaryColor() -> UIColor? {
        return page.primaryColor
    }
    
    func getPrimaryTextColor() -> UIColor? {
        return page.primaryTextColor
    }
    
    func getTextColor() -> UIColor? {
        return page.textColor
    }
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType] {
        return page.getAnalyticsEvents(type: .visible).map({MultiplatformAnalyticsEvent(analyticsEvent: $0)})
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformChooseYourOwnAdventurePage {
    
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

        //childModels.append(MultiplatformContent(content: page.content))
        
        return childModels
    }
}
