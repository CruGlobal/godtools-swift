//
//  MenuSectionView.swift
//  godtools
//
//  Created by Aaron Laib on 6/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct MenuSectionView<Content: View>: View {
        
    let sectionTitle: String
    let menuItemsViewBuilder: () -> Content
    
    init(sectionTitle: String, @ViewBuilder menuItemsViewBuilder: @escaping () -> Content) {
        
        self.sectionTitle = sectionTitle
        self.menuItemsViewBuilder = menuItemsViewBuilder
    }
        
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text(sectionTitle)
                .padding(EdgeInsets(top: MenuView.sectionTitleVerticalSpacing, leading: 0, bottom: MenuView.itemSpacing / 2, trailing: 0))
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextRegular.font(size: 17))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 0) {
                
                let menuItems = menuItemsViewBuilder()
                
                menuItems
                
                let hasMenuItems: Bool = !(menuItems is EmptyView)
                
                if hasMenuItems {
                    
                    Rectangle()
                        .fill(ColorPalette.gtLightestGrey.color)
                        .frame(height: 1)
                        .padding(EdgeInsets(top: MenuView.itemSpacing / 2, leading: 0, bottom: 0, trailing: 0))
                }
            }
        }
    }
}
