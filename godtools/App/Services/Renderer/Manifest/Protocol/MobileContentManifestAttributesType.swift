//
//  MobileContentManifestAttributesType.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol MobileContentManifestAttributesType: BackgroundImageModelType {
    
    var backgroundColor: UIColor { get }
    var backgroundImage: String? { get }
    var backgroundImageAlignments: [MobileContentBackgroundImageAlignment] { get }
    var backgroundImageScale: MobileContentBackgroundImageScale { get }
    var categoryLabelColor: String? { get }
    var dismissListeners: [String] { get }
    var locale: String? { get }
    var navbarColor: UIColor? { get }
    var navbarControlColor: UIColor? { get }
    var primaryColor: UIColor { get }
    var primaryTextColor: UIColor { get }
    var textColor: UIColor { get }
    var textScale: MobileContentTextScale { get }
    var tool: String? { get }
    var type: String? { get }
}
