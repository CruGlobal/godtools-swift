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
        backItem: BackToolbarItem?,
        @ToolbarContentBuilder toolbarContent: () -> Content = { AppToolbarItem?.none }
    ) -> some View {
        
        navigationTitle(title ?? "")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                
                if let backItem = backItem {
                    
                    backItem
                }
                
                toolbarContent()
            }
    }
}
