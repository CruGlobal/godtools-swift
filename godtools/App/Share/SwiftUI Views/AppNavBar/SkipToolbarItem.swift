//
//  SkipToolbarItem.swift
//  godtools
//
//  Created by Levi Eggert on 8/26/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct SkipToolbarItem: ToolbarContent {
    
    private let title: String
    private let tapped: (() -> Void)
    private let color: Color
        
    init(
        title: String,
        tapped: @escaping () -> Void,
        color: Color = ColorPalette.gtBlue.color
    ) {
        
        self.title = title
        self.tapped = tapped
        self.color = color
    }
    
    var body: some ToolbarContent {
        
        AppToolbarItem(
            placement: AppToolbarItem.trailingPlacement,
            viewType: .text(value: title),
            color: color,
            accessibilityId: AccessibilityStrings.Button.skip.id,
            tapped: tapped
        )
    }
}
