//
//  AccountActivityView.swift
//  godtools
//
//  Created by Rachael Skeath on 1/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct AccountActivityView: View {
    
    private let itemSpacing: CGFloat = 18
    
    @ObservedObject var viewModel: AccountViewModel
    
    let sectionFrameWidth: CGFloat
    
    var body: some View {
        
        let itemSpacingTotal = itemSpacing * 2
        let itemWidthHeight: CGFloat = (sectionFrameWidth - itemSpacingTotal) / 3
        
        VStack(alignment: .leading) {
            
            Text("Your Badges")
                .font(FontLibrary.sfProTextRegular.font(size: 22))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding(.top, 40)
            
            let columns = [
                GridItem(.fixed(itemWidthHeight), spacing: itemSpacing),
                GridItem(.fixed(itemWidthHeight), spacing: itemSpacing),
                GridItem(.fixed(itemWidthHeight), spacing: itemSpacing)
            ]
            
            LazyVGrid(columns: columns, spacing: itemSpacing) {
                
                ForEach(viewModel.badges) { badge in
                    
                    AccountActivityBadgeView(badge: badge)
                    .frame(width: itemWidthHeight, height: itemWidthHeight)
                }
            }
        }
        .padding(.bottom, 20)
    }
}
