//
//  ContentLinkModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol ContentLinkModelType: MobileContentRenderableModel {
    
    var events: [String] { get }
    var text: String? { get }
    
    func getTextColor() -> UIColor?
    func getAnalyticsEvents() -> [AnalyticsEventModelType]
}

extension ContentLinkModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
