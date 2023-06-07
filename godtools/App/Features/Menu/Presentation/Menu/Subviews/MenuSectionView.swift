//
//  MenuSectionView.swift
//  godtools
//
//  Created by Aaron Laib on 6/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct MenuSectionView: View {
    
    private let sectionTitleVerticalPadding: CGFloat = 24
    private let menuItemSpacing: CGFloat = 24
    
    let sectionTitle: String
    let menuItems: [MenuItemData]
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text(sectionTitle)
                .padding(EdgeInsets(top: sectionTitleVerticalPadding, leading: 0, bottom: sectionTitleVerticalPadding, trailing: 0))
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextRegular.font(size: 17))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: menuItemSpacing) {
                
                ForEach(0 ..< menuItems.count, id: \.self) { index in
                    
                    MenuItemView(menuItemData: menuItems[index], tappedClosure: {
                        
                        print("menu item tapped at index: \(index)")
                    })
                }
            }
            
            let hasMenuItems: Bool = menuItems.count > 0
            
            if hasMenuItems {
                
                Rectangle()
                    .fill(ColorPalette.gtLightestGrey.color)
                    .frame(height: 1)
                    .padding(EdgeInsets(top: sectionTitleVerticalPadding, leading: 0, bottom: 0, trailing: 0))
            }
        }
    }
}
