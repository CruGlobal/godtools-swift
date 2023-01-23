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
        
        VStack {
            
            Text("Your Badges")
            
            let columns = [
                GridItem(.fixed(itemWidthHeight), spacing: itemSpacing),
                GridItem(.fixed(itemWidthHeight), spacing: itemSpacing),
                GridItem(.fixed(itemWidthHeight), spacing: itemSpacing)
            ]
            
            LazyVGrid(columns: columns, spacing: itemSpacing) {
                
                ForEach(viewModel.badges) { badge in
                    
                    ZStack(alignment: .center) {
                        
                        Color.white
                            .cornerRadius(10)
                            .shadow(
                                color: Color.black.opacity(0.3),
                                radius: 4,
                                x: 1,
                                y: 1
                            )
                        
                        VStack(alignment: .center, spacing: 7) {
                            
                            ZStack(alignment: .center) {
                                Image("badge_background")
                                    .foregroundColor(badge.iconBackgroundColor)
                                Image(badge.iconImageName)
                                    .foregroundColor(badge.iconForegroundColor)
                            }
                            
                            Text(badge.badgeText)
                                .font(FontLibrary.sfProTextRegular.font(size: 10))
                                .foregroundColor(ColorPalette.gtGrey.color)
                        }
                    }
                    .frame(width: itemWidthHeight, height: itemWidthHeight)
                }
            }
        }
    }
}
