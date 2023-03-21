//
//  AccountActivityView.swift
//  godtools
//
//  Created by Rachael Skeath on 1/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct AccountActivityView: View {
        
    @ObservedObject var viewModel: AccountViewModel
    
    let sectionFrameWidth: CGFloat
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            activitySection()
            
            badgesSection()
        }
        .padding(.bottom, 20)
    }
    
    @ViewBuilder func activitySection() -> some View {
        
        let leadingPaddingRatio: CGFloat = 15 / 335
        let leadingPadding = sectionFrameWidth * leadingPaddingRatio
        let itemWidth: CGFloat = sectionFrameWidth / 2
        
        VStack(alignment: .leading) {

            Text("Your activity")
                .font(FontLibrary.sfProTextRegular.font(size: 22))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding(.top, 20)
            
            ZStack(alignment: .center) {
                
                Color.white
                    .cornerRadius(10)
                    .shadow(
                        color: Color.black.opacity(0.15),
                        radius: 5,
                        x: 0,
                        y: 3
                    )
                                    
                let columns = [
                    GridItem(.fixed(itemWidth - leadingPadding), spacing: 0, alignment: .leading),
                    GridItem(.fixed(itemWidth), spacing: 0, alignment: .leading)
                ]
                
                LazyVGrid(columns: columns, spacing: 26) {
                    
                    ForEach(viewModel.stats) { stat in
                        
                        AccountActivityStatView(stat: stat)
                    }
                }
                .padding([.top, .bottom], 21)
                .padding(.leading, leadingPadding)
            }
        }
    }
    
    @ViewBuilder func badgesSection() -> some View {
        
        let itemSpacing: CGFloat = 18
        let itemSpacingTotal = itemSpacing * 2
        let itemWidthHeight: CGFloat = (sectionFrameWidth - itemSpacingTotal) / 3
        
        VStack(alignment: .leading) {
            
            Text(viewModel.badgesSectionTitle)
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
    }
}
