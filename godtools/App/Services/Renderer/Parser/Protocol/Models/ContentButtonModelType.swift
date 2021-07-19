//
//  ContentButtonModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ContentButtonModelType: MobileContentRenderableModel {
    
    var backgroundColor: String? { get }
    var color: String? { get }
    var events: [String] { get }
    var style: String? { get }
    var type: String? { get }
    var url: String? { get }
    var buttonStyle: MobileContentButtonStyle? { get }
    var buttonType: MobileContentButtonType { get }
    var text: String? { get }
    
    func getBackgroundColor() -> MobileContentRGBAColor?
    func getColor() -> MobileContentRGBAColor?
    func getTextColor() -> MobileContentRGBAColor?
    func getAnalyticsEvents() -> [AnalyticsEventModelType]
}

extension ContentButtonModelType {
    var modelContentIsRenderable: Bool {
        return buttonType != .unknown
    }
}
