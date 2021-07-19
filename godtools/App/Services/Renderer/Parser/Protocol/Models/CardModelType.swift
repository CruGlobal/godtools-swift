//
//  CardModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol CardModelType: BackgroundImageModelType, MobileContentRenderableModel {
    
    var backgroundImage: String? { get }
    var backgroundImageAlign: [String] { get }
    var backgroundImageScaleType: String { get }
    var dismissListeners: [String] { get }
    var hidden: String? { get }
    var listeners: [String] { get }
    var isHidden: Bool { get }
    var text: String? { get }
    var hasTrainingTip: Bool { get }
    var cardPositionInVisibleCards: Int { get }
    var numberOfVisibleCards: Int { get }
    
    func getTextColor() -> MobileContentRGBAColor?
    func getAnalyticsEvents() -> [AnalyticsEventModelType]
}

extension CardModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
