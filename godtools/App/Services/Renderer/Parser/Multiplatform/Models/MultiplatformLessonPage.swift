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
    
    var id: String {
        return lessonPage.id
    }
    
    var backgroundImage: String? {
        return lessonPage.backgroundImage?.name
    }
    
    var backgroundImageAlignment: Gravity? {
        return lessonPage.backgroundImageGravity
    }
    
    var backgroundImageScale: ImageScaleType {
        return lessonPage.backgroundImageScaleType
    }
    
    var listeners: [EventId] {
        return Array(lessonPage.listeners)
    }
    
    var textScale: Double {
        return lessonPage.textScale
    }
    
    var isHidden: Bool {
        return lessonPage.isHidden
    }
    
    var hero: Hero? {
        return nil
    }
    
    var callToAction: CallToAction? {
        return nil
    }
    
    func getBackgroundColor() -> UIColor? {
        return lessonPage.backgroundColor
    }
    
    func getCardTextColor() -> UIColor? {
        return nil
    }
    
    func getPrimaryColor() -> UIColor? {
        return lessonPage.primaryColor
    }
    
    func getPrimaryTextColor() -> UIColor? {
        return lessonPage.primaryTextColor
    }
    
    func getTextColor() -> UIColor? {
        return lessonPage.textColor
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
