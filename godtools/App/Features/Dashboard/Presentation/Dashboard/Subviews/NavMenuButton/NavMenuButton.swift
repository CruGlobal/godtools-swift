//
//  NavMenuButton.swift
//  godtools
//
//  Created by Levi Eggert on 1/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct NavMenuButton: View {
    
    let tappedClosure: (() -> Void)?
    
    init(tappedClosure: (() -> Void)?) {
        
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        CustomButton(
            attributes: CustomButtonAttributes(width: 32, height: 32, color: .clear),
            accessibilityId: AccessibilityStrings.Button.dashboardMenu.id,
            highlightContent: {
                ImageCatalog
                    .navMenu
                    .image
                    .resizable()
                    .renderingMode(.template)
                    .tint(ColorPalette.gtBlue.color)
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    
            },
            nonHighlightContent: {
                
            },
            tappedClosure: tappedClosure
        )
    }
}
