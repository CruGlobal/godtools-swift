//
//  ContentLinkModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ContentLinkModelType: MobileContentRenderableModel {
    
    var events: [MultiplatformEventId] { get }
    var text: String? { get }
    
    func getTextColor() -> MobileContentColor?
    func getAnalyticsEvents() -> [AnalyticsEventModelType]
}

extension ContentLinkModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
