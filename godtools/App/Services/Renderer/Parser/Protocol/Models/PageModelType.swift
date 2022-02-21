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
    var backgroundImageAlignment: Gravity? { get }
    var backgroundImageScale: ImageScaleType { get }
    var listeners: [EventId] { get }
    var textScale: Double { get }
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
