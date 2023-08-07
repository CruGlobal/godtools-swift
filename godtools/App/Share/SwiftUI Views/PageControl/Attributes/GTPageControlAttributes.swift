//
//  GTPageControlAttributes.swift
//  godtools
//
//  Created by Levi Eggert on 8/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct GTPageControlAttributes: PageControlAttributesType {
    
    let deselectedColor: Color = ColorPalette.gtLightestGrey.color
    let selectedColor: Color = ColorPalette.gtBlue.color
    let circleSize: CGFloat = 7.5
    let circleSpacing: CGFloat = 10
}
