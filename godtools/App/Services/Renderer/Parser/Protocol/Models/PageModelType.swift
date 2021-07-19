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
    var backgroundImage: String? { get }
    var backgroundImageAlignments: [MobileContentBackgroundImageAlignment] { get }
    var backgroundImageScale: MobileContentBackgroundImageScale { get }
    var listeners: [String] { get }
    var textScale: Double { get }
    var isHidden: Bool { get }
    var hero: HeroModelType? { get }
    var callToAction: CallToActionModelType? { get }
    
    func getBackgroundColor() -> UIColor?
    func getCardTextColor() -> UIColor?
    func getPrimaryColor() -> UIColor?
    func getPrimaryTextColor() -> UIColor?
    func getTextColor() -> UIColor?
}

extension PageModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
