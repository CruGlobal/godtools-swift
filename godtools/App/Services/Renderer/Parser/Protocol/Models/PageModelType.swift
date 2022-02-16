//
//  PageModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol PageModelType: BackgroundImageModelType, MobileContentRenderableModel {
        
    var id: String { get }
    var uuid: String { get }
    var backgroundImage: String? { get }
    var backgroundImageAlignment: MobileContentImageAlignmentType { get }
    var backgroundImageScale: MobileContentBackgroundImageScale { get }
    var listeners: [MultiplatformEventId] { get }
    var textScale: MobileContentTextScale { get }
    var isHidden: Bool { get }
    var hero: HeroModelType? { get }
    var callToAction: CallToActionModelType? { get }
    
    func getBackgroundColor() -> MobileContentColor?
    func getCardTextColor() -> MobileContentColor?
    func getPrimaryColor() -> MobileContentColor?
    func getPrimaryTextColor() -> MobileContentColor?
    func getTextColor() -> MobileContentColor?
    func getAnalyticsEvents() -> [AnalyticsEventModelType]
}

extension PageModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
