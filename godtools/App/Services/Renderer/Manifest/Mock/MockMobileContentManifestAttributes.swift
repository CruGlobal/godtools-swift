//
//  MockMobileContentManifestAttributes.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MockMobileContentManifestAttributes: MobileContentManifestAttributesType {
    
    let backgroundColor: UIColor = .lightGray
    let backgroundImage: String? = nil
    let backgroundImageAlignments: [MobileContentBackgroundImageAlignment] = []
    let backgroundImageScale: MobileContentBackgroundImageScale = .fill
    let categoryLabelColor: String? = nil
    let dismissListeners: [String] = []
    let locale: String? = nil
    let navbarColor: UIColor? = nil
    let navbarControlColor: UIColor? = nil
    let primaryColor: UIColor = .darkGray
    let primaryTextColor: UIColor = .black
    let textColor: UIColor = .black
    let textScale: MobileContentTextScale = MobileContentTextScale(textScaleString: nil)
    let tool: String? = nil
    let type: String? = nil
    
    required init() {
        
    }
}
