//
//  PageModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol PageModelType: BackgroundImageModelType {
        
    var backgroundColor: String? { get }
    var backgroundImage: String? { get }
    var backgroundImageAlign: [String] { get }
    var backgroundImageScaleType: String { get }
    var cardTextColor: String? { get }
    var hidden: String? { get }
    var listeners: [String] { get }
    var primaryColor: String? { get }
    var primaryTextColor: String? { get }
    var textColor: String? { get }
    var textScale: String? { get }
    var isHidden: Bool { get }
    var hero: HeroModelType? { get }
    var callToAction: CallToActionModelType? { get }
    
    func getBackgroundColor() -> MobileContentRGBAColor?
    func getCardTextColor() -> MobileContentRGBAColor?
    func getPrimaryColor() -> MobileContentRGBAColor?
    func getPrimaryTextColor() -> MobileContentRGBAColor?
    func getTextColor() -> MobileContentRGBAColor?
}
