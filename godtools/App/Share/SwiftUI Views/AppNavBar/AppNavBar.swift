//
//  AppNavBar.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

extension View {
    
    func navBar<Content: ToolbarContent>(
        title: String?,
        backTapped: (() -> Void)?,
        @ToolbarContentBuilder toolbarContent: () -> Content = { AppToolbarItem?.none }
    ) -> some View {
        
        navigationTitle(title ?? "")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                
                if backTapped != nil {
                    
                    AppToolbarItem(
                        placement: AppToolbarItem.leadingPlacement,
                        viewType: .image(value: ImageCatalog.navBack.image),
                        color: ColorPalette.gtBlue.color,
                        accessibilityId: AccessibilityStrings.Button.back.id,
                        tappedClosure: {
                            backTapped?()
                        }
                    )
                }
                
                toolbarContent()
            }
    }
}
