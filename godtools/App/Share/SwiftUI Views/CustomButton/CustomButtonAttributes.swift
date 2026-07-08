//
//  CustomButtonAttributes.swift
//  godtools
//
//  Created by Levi Eggert on 1/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftUI

struct CustomButtonAttributes {
    
    let width: CGFloat?
    let height: CGFloat?
    let backgroundHorizontalPadding: CGFloat?
    let backgroundVerticalPadding: CGFloat?
    let color: Color
    let cornerRadius: CGFloat
    let borderColor: Color
    let borderWidth: CGFloat
    
    init(
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        backgroundHorizontalPadding: CGFloat? = nil,
        backgroundVerticalPadding: CGFloat? = nil,
        color: Color = Color.clear,
        cornerRadius: CGFloat = 0,
        borderColor: Color = Color.clear,
        borderWidth: CGFloat = 0
    ) {
        
        self.width = width
        self.height = height
        self.backgroundHorizontalPadding = backgroundHorizontalPadding
        self.backgroundVerticalPadding = backgroundVerticalPadding
        self.color = color
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
}
