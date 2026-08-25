//
//  BackToolbarItem.swift
//  godtools
//
//  Created by Levi Eggert on 8/25/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct BackToolbarItem: ToolbarContent {
    
    private let tapped: (() -> Void)
    private let color: Color
    
    init(tapped: @escaping () -> Void, color: Color = ColorPalette.gtBlue.color) {
        
        self.color = color
        self.tapped = tapped
    }
    
    var body: some ToolbarContent {
        
        AppToolbarItem(
            placement: AppToolbarItem.leadingPlacement,
            viewType: .image(value: ImageCatalog.navBack.image),
            color: color,
            accessibilityId: AccessibilityStrings.Button.back.id,
            tappedClosure: {
                tapped()
            }
        )
    }
}
