//
//  MobileContentManifestAttributesType.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol MobileContentManifestAttributesType: BackgroundImageModelType {
    
    var backgroundColor: String { get }
    var backgroundImage: String? { get }
    var backgroundImageAlign: [String] { get }
    var backgroundImageScaleType: String { get }
    var categoryLabelColor: String? { get }
    var dismissListeners: [String] { get }
    var locale: String? { get }
    var navbarColor: String? { get }
    var navbarControlColor: String? { get }
    var primaryColor: String { get }
    var primaryTextColor: String { get }
    var textColor: String { get }
    var textScale: String? { get }
    var tool: String? { get }
    var type: String? { get }
    
    func getBackgroundColor() -> MobileContentRGBAColor
    func getNavBarColor() -> MobileContentRGBAColor?
    func getNavBarControlColor() -> MobileContentRGBAColor?
    func getPrimaryColor() -> MobileContentRGBAColor
    func getPrimaryTextColor() -> MobileContentRGBAColor
    func getTextColor() -> MobileContentRGBAColor
}
