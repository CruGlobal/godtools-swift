//
//  NavMenuButton.swift
//  godtools
//
//  Created by Levi Eggert on 1/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct NavMenuButton: View {
    
    static let size: CGFloat = 32
    static let iconSize: CGFloat = 22
    
    let tappedClosure: (() -> Void)?
    
    init(tappedClosure: (() -> Void)?) {
        
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        CustomButton(
            attributes: CustomButtonAttributes(width: Self.size, height: Self.size, color: .clear),
            accessibilityId: AccessibilityStrings.Button.dashboardMenu.id,
            highlightContent: {
                ImageCatalog
                    .navMenu
                    .image
                    .resizable()
                    .renderingMode(.template)
                    .tint(ColorPalette.gtBlue.color)
                    .scaledToFit()
                    .frame(width: Self.iconSize, height: Self.iconSize)
                    
            },
            nonHighlightContent: {
                
            },
            tappedClosure: tappedClosure
        )
    }
}
