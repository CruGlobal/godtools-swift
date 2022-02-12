//
//  MultiplatformContentPage.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MultiplatformContentPage: PageModelType {
    
    private let contentPage: ContentPage
    
    let uuid: String = UUID().uuidString
    
    required init(contentPage: ContentPage) {
        
        self.contentPage = contentPage
    }
    
    var backgroundImage: String? {
        return contentPage.backgroundImage?.name
    }
    
    var backgroundImageAlignment: MobileContentImageAlignmentType {
        return MultiplatformImageAlignment(imageGravity: contentPage.backgroundImageGravity)
    }
    
    var backgroundImageScale: MobileContentBackgroundImageScale {
        switch contentPage.backgroundImageScaleType {
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
        return contentPage.listeners.map({MultiplatformEventId(eventId: $0)})
    }
    
    var textScale: MobileContentTextScale {
        return MobileContentTextScale(doubleValue: contentPage.textScale)
    }
    
    var isHidden: Bool {
        return contentPage.isHidden
    }
    
    var hero: Hero? {
        return nil
    }
    
    var callToAction: CallToAction? {
        return nil
    }
    
    func getBackgroundColor() -> UIColor? {
        return contentPage.backgroundColor
    }
    
    func getCardTextColor() -> UIColor? {
        return nil
    }
    
    func getPrimaryColor() -> UIColor? {
        return contentPage.primaryColor
    }
    
    func getPrimaryTextColor() -> UIColor? {
        return contentPage.primaryTextColor
    }
    
    func getTextColor() -> UIColor? {
        return contentPage.textColor
    }
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType] {
        return contentPage.getAnalyticsEvents(type: .visible).map({MultiplatformAnalyticsEvent(analyticsEvent: $0)})
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContentPage {
    
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
                
        let multiplatformContent: MultiplatformContent = MultiplatformContent(
            content: contentPage.content,
            contentInsets: .zero,
            itemSpacing: 20,
            scrollIsEnabled: true
        )

        childModels.append(multiplatformContent)
        
        return childModels
    }
}
