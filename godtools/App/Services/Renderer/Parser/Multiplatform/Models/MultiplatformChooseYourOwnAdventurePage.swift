//
//  MultiplatformChooseYourOwnAdventurePage.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
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
    
    var backgroundImageAlignment: Gravity? {
        return page.backgroundImageGravity
    }
    
    var backgroundImageScale: ImageScaleType {
        return page.backgroundImageScaleType
    }
    
    var listeners: [EventId] {
        return Array(page.listeners)
    }
    
    var textScale: Double {
        return page.textScale
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
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        
        var childModels: [MobileContentRenderableModel] = Array()

        //childModels.append(MultiplatformContent(content: page.content))
        
        return childModels
    }
}
