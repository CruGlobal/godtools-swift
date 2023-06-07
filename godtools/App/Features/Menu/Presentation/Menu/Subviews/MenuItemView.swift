//
//  MenuItemView.swift
//  godtools
//
//  Created by Aaron Laib on 6/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct MenuItemView: View {
    
    let menuItemData: MenuItemData
    let tappedClosure: (() -> Void)

    var body: some View {
        
        HStack {
            
            Image(menuItemData.iconName)
                .frame(width: 24)
            
            Text(menuItemData.title)
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextRegular.font(size: 16))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture {
            tappedClosure()
        }
    }
}

