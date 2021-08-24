//
//  MobileContentManifestAttributesType.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol MobileContentManifestAttributesType: BackgroundImageModelType {
    
    var backgroundColor: MobileContentColor { get }
    var backgroundImage: String? { get }
    var backgroundImageAlignment: MobileContentImageAlignmentType { get }
    var backgroundImageScale: MobileContentBackgroundImageScale { get }
    var categoryLabelColor: MobileContentColor? { get }
    var dismissListeners: [String] { get }
    var locale: String? { get }
    var navbarColor: MobileContentColor? { get }
    var navbarControlColor: MobileContentColor? { get }
    var primaryColor: MobileContentColor { get }
    var primaryTextColor: MobileContentColor { get }
    var textColor: MobileContentColor { get }
    var textScale: MobileContentTextScale { get }
}
