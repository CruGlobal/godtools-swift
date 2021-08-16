//
//  MultiplatformContentLink.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentLink: ContentLinkModelType {
    
    private let link: Link
    
    required init(link: Link) {
        
        self.link = link
    }
    
    var events: [String] {
        return link.events.map({$0.description()})
    }
    
    var text: String? {
        return link.text?.text
    }
    
    func getTextColor() -> MobileContentColor? {
        return MobileContentColor(color: link.textColor)
    }
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType] {
        return link.analyticsEvents.map({MultiplatformAnalyticsEvent(analyticsEvent: $0)})
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContentLink {
    
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
        return Array()
    }
}
