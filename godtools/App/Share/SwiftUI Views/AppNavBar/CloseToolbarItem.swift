//
//  CloseToolbarItem.swift
//  godtools
//
//  Created by Levi Eggert on 8/25/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct CloseToolbarItem: ToolbarContent {
    
    private let tapped: (() -> Void)
    private let color: Color
    
    let placement: ToolbarItemPlacement
    
    init(
        tapped: @escaping () -> Void,
        color: Color = ColorPalette.gtBlue.color,
        placement: ToolbarItemPlacement = AppToolbarItem.trailingPlacement
    ) {
        
        self.tapped = tapped
        self.color = color
        self.placement = placement
    }
    
    var body: some ToolbarContent {
        
        AppToolbarItem(
            placement: placement,
            viewType: .image(value: ImageCatalog.navClose.image),
            color: color,
            accessibilityId: AccessibilityStrings.Button.close.id,
            tapped: tapped
        )
    }
}
