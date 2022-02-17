//
//  PageModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

protocol PageModelType: BackgroundImageModelType, MobileContentRenderableModel {
        
    var id: String { get }
    var uuid: String { get }
    var backgroundImage: String? { get }
    var backgroundImageAlignment: MobileContentImageAlignmentType { get }
    var backgroundImageScale: MobileContentBackgroundImageScale { get }
    var listeners: [MultiplatformEventId] { get }
    var textScale: MobileContentTextScale { get }
    var isHidden: Bool { get }
    var hero: Hero? { get }
    var callToAction: CallToAction? { get }
    
    func getBackgroundColor() -> UIColor?
    func getCardTextColor() -> UIColor?
    func getPrimaryColor() -> UIColor?
    func getPrimaryTextColor() -> UIColor?
    func getTextColor() -> UIColor?
    func getAnalyticsEvents() -> [AnalyticsEventModelType]
}

extension PageModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
