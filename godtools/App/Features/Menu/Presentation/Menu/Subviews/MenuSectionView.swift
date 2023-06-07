//
//  MenuSectionView.swift
//  godtools
//
//  Created by Aaron Laib on 6/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct MenuSectionView: View {
    
    private let sectionTitlePadding: CGFloat = 19
    private let menuItemSpacing: CGFloat = 19
    
    let sectionTitle: String
    let menuItems: [MenuItemData]
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text(sectionTitle)
                .padding(EdgeInsets(top: sectionTitlePadding, leading: 0, bottom: sectionTitlePadding, trailing: 0))
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextRegular.font(size: 17))
            
            VStack(alignment: .leading, spacing: menuItemSpacing) {
                ForEach(0 ..< menuItems.count, id: \.self) { index in
                    
                    MenuItemView(menuItemData: menuItems[index])
                }
            }
        }
        
        let hasMenuItems: Bool = menuItems.count > 0
        
        if hasMenuItems {
            Divider()
                .padding(EdgeInsets(top: sectionTitlePadding, leading: 0, bottom: 0, trailing: 0))
        }
    }
}
