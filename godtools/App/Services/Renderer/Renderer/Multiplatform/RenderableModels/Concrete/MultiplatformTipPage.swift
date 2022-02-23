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
    
    var id: String {
        return ""
    }
    
    var backgroundImage: String? {
        return nil
    }
    
    var backgroundImageAlignment: Gravity? {
        return nil
    }
    
    var backgroundImageScale: ImageScaleType {
        return .fill
    }
    
    var listeners: [EventId] {
        return Array()
    }
    
    var textScale: Double {
        return 1
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
    
    func getBackgroundColor() -> UIColor? {
        return nil
    }
    
    func getCardTextColor() -> UIColor? {
        return nil
    }
    
    func getPrimaryColor() -> UIColor? {
        return nil
    }
    
    func getPrimaryTextColor() -> UIColor? {
        return nil
    }
    
    func getTextColor() -> UIColor? {
        return nil
    }
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType] {
        return []
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformTipPage {
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        
        var childModels: [MobileContentRenderableModel] = Array()
        
        addContentToChildModels(childModels: &childModels, content: tipPage.content)
        
        return childModels
    }
}
