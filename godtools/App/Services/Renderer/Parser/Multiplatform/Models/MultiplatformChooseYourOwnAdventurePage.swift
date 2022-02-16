//
//  MultiplatformChooseYourOwnAdventurePage.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

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
    
    var hero: HeroModelType? {
        return nil
    }
    
    var callToAction: CallToActionModelType? {
        return nil
    }
    
    func getBackgroundColor() -> MobileContentColor? {
        return MobileContentColor(color: page.backgroundColor)
    }
    
    func getCardTextColor() -> MobileContentColor? {
        return nil
    }
    
    func getPrimaryColor() -> MobileContentColor? {
        return MobileContentColor(color: page.primaryColor)
    }
    
    func getPrimaryTextColor() -> MobileContentColor? {
        return MobileContentColor(color: page.primaryTextColor)
    }
    
    func getTextColor() -> MobileContentColor? {
        return MobileContentColor(color: page.textColor)
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
