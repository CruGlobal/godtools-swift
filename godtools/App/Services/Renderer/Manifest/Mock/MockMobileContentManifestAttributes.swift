//
//  MockMobileContentManifestAttributes.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MockMobileContentManifestAttributes: MobileContentManifestAttributesType {
    
    let backgroundColor: MobileContentColor = MobileContentColor(color: .lightGray)
    let backgroundImage: String? = nil
    let backgroundImageAlignment: Gravity? = nil
    let backgroundImageScale: ImageScaleType = .fill
    let categoryLabelColor: MobileContentColor? = nil
    let dismissListeners: [MultiplatformEventId] = []
    let locale: String? = nil
    let navbarColor: MobileContentColor? = nil
    let navbarControlColor: MobileContentColor? = nil
    let primaryColor: MobileContentColor = MobileContentColor(color: .darkGray)
    let primaryTextColor: MobileContentColor = MobileContentColor(color: .black)
    let textColor: MobileContentColor = MobileContentColor(color: .black)
    let textScale: MobileContentTextScale = MobileContentTextScale(textScaleString: nil)
    
    required init() {
        
    }
}
