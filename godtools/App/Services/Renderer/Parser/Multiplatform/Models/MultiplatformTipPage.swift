//
//  MultiplatformTipPage.swift
//  godtools
//
//  Created by Levi Eggert on 8/16/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformTipPage: PageModelType {
    
    private let tipPage: TipPage
    
    let uuid: String = UUID().uuidString
    
    required init(tipPage: TipPage) {
        
        self.tipPage = tipPage
    }
    
    var backgroundImage: String? {
        return nil
    }
    
    var backgroundImageAlignment: MobileContentImageAlignmentType {
        return MobileContentImageAlignment(isCenter: false, isCenterX: false, isCenterY: false, isStart: true, isEnd: false, isTop: true, isBottom: false)
    }
    
    var backgroundImageScale: MobileContentBackgroundImageScale {
        return .fill
    }
    
    var listeners: [MultiplatformEventId] {
        return Array()
    }
    
    var textScale: MobileContentTextScale {
        return MobileContentTextScale(doubleValue: 1)
    }
    
    var isHidden: Bool {
        return false
    }
    
    var hero: Hero? {
        return nil
    }
    
    var callToAction: CallToAction? {
        return nil
    }
    
    func getBackgroundColor() -> MobileContentColor? {
        return nil
    }
    
    func getCardTextColor() -> MobileContentColor? {
        return nil
    }
    
    func getPrimaryColor() -> MobileContentColor? {
        return nil
    }
    
    func getPrimaryTextColor() -> MobileContentColor? {
        return nil
    }
    
    func getTextColor() -> MobileContentColor? {
        return nil
    }
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType] {
        return []
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformTipPage {
    
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
        
        addContentToChildModels(childModels: &childModels, content: tipPage.content)
        
        return childModels
    }
}
