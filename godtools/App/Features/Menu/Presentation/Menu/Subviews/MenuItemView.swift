//
//  MenuItemView.swift
//  godtools
//
//  Created by Aaron Laib on 6/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct MenuItemView: View {
    
    let imageAssetName: String
    let title: String
    let tappedClosure: (() -> Void)

    var body: some View {
        
        HStack {
            
            Image(imageAssetName)
                .frame(width: 24)
            
            Button(action: {

                tappedClosure()
            }) {
                
                Text(title)
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .font(FontLibrary.sfProTextRegular.font(size: 16))
                    .padding(EdgeInsets(top: MenuView.itemSpacing / 2, leading: 0, bottom: MenuView.itemSpacing / 2, trailing: 0))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
        }
    }
}

