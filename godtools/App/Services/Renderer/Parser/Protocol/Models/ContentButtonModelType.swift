//
//  ContentButtonModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol ContentButtonModelType: MobileContentRenderableModel {
    
    var events: [String] { get }
    var url: String? { get }
    var style: MobileContentButtonStyle? { get }
    var type: MobileContentButtonType { get }
    var text: String? { get }
    
    func getBackgroundColor() -> UIColor?
    func getColor() -> UIColor?
    func getTextColor() -> UIColor?
    func getAnalyticsEvents() -> [AnalyticsEventModelType]
}

extension ContentButtonModelType {
    var modelContentIsRenderable: Bool {
        return type != .unknown
    }
}
