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
    var backgroundImageAlignment: MobileContentImageAlignmentType { get }
    var backgroundImageScale: MobileContentBackgroundImageScale { get }
    var dismissListeners: [String] { get }
    var listeners: [String] { get }
    var isHidden: Bool { get }
    var title: String? { get }
    var hasTrainingTip: Bool { get }
    var cardPositionInVisibleCards: Int { get }
    var numberOfVisibleCards: Int { get }
    
    func getTitleColor() -> MobileContentColor?
    func getAnalyticsEvents() -> [AnalyticsEventModelType]
}

extension CardModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
