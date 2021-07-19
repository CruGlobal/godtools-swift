//
//  PageModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol PageModelType: BackgroundImageModelType, MobileContentRenderableModel {
        
    var uuid: String { get }
    var backgroundColor: UIColor? { get }
    var backgroundImage: String? { get }
    var backgroundImageAlign: [String] { get }
    var backgroundImageScaleType: String { get }
    var cardTextColor: UIColor? { get }
    var listeners: [String] { get }
    var primaryColor: UIColor? { get }
    var primaryTextColor: UIColor? { get }
    var textColor: UIColor? { get }
    var textScale: Double { get }
    var isHidden: Bool { get }
    var hero: HeroModelType? { get }
    var callToAction: CallToActionModelType? { get }
}

extension PageModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
