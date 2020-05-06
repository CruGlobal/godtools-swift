//
//  TractHeadingProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractHeadingProperties: TractProperties {
    let defaultHeadingFontSize: CGFloat = 30.0
    
    override func getTextProperties() -> TractTextContentProperties {
        let properties = super.getTextProperties()
        properties.font = .gtRegular(size: defaultHeadingFontSize)
        return properties
    }
}
