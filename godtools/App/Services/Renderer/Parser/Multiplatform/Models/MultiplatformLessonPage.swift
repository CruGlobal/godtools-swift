//
//  MultiplatformLessonPage.swift
//  godtools
//
//  Created by Levi Eggert on 8/11/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MultiplatformLessonPage: PageModelType {
    
    private let lessonPage: LessonPage
    
    let uuid: String = UUID().uuidString
    
    required init(lessonPage: LessonPage) {
        
        self.lessonPage = lessonPage
    }
    
    var backgroundImage: String? {
        return lessonPage.backgroundImage?.name
    }
    
    var backgroundImageAlignment: MobileContentImageAlignmentType {
        return MultiplatformImageAlignment(imageGravity: lessonPage.backgroundImageGravity)
    }
    
    var backgroundImageScale: MobileContentBackgroundImageScale {
        switch lessonPage.backgroundImageScaleType {
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
        return lessonPage.listeners.map({MultiplatformEventId(eventId: $0)})
    }
    
    var textScale: MobileContentTextScale {
        return MobileContentTextScale(doubleValue: lessonPage.textScale)
    }
    
    var isHidden: Bool {
        return lessonPage.isHidden
    }
    
    var hero: HeroModelType? {
        return nil
    }
    
    var callToAction: CallToActionModelType? {
        return nil
    }
    
    func getBackgroundColor() -> MobileContentColor? {
        return MobileContentColor(color: lessonPage.backgroundColor)
    }
    
    func getCardTextColor() -> MobileContentColor? {
        return nil
    }
    
    func getPrimaryColor() -> MobileContentColor? {
        return MobileContentColor(color: lessonPage.primaryColor)
    }
    
    func getPrimaryTextColor() -> MobileContentColor? {
        return MobileContentColor(color: lessonPage.primaryTextColor)
    }
    
    func getTextColor() -> MobileContentColor? {
        return MobileContentColor(color: lessonPage.textColor)
    }
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType] {
        return lessonPage.getAnalyticsEvents(type: .visible).map({MultiplatformAnalyticsEvent(analyticsEvent: $0)})
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformLessonPage {
    
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

        let contentHorizontalInsets: CGFloat = 30
        
        let multiplatformContent = MultiplatformContent(
            content: lessonPage.content,
            contentInsets: UIEdgeInsets(top: 0, left: contentHorizontalInsets, bottom: 0, right: contentHorizontalInsets),
            itemSpacing: 20,
            scrollIsEnabled: true
        )
        
        childModels.append(multiplatformContent)
        
        return childModels
    }
}
