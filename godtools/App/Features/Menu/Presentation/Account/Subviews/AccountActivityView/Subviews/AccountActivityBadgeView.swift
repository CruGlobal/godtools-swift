//
//  AccountActivityBadgeView.swift
//  godtools
//
//  Created by Rachael Skeath on 1/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct AccountActivityBadgeView: View {
    
    let badge: UserActivityBadgeDomainModel
    
    let lightGreyTextColor = Color(red: 203 / 255, green: 203 / 255, blue: 203 / 255)
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            badgeBackground(withShadow: badge.isEarned)
            
            VStack(alignment: .center, spacing: 7) {
                
                ZStack(alignment: .center) {
                    Image("badge_background")
                        .foregroundColor(badge.iconBackgroundColor)
                    Image(badge.iconImageName)
                        .foregroundColor(badge.iconForegroundColor)
                }
                
                Text(badge.badgeText)
                    .font(FontLibrary.sfProTextRegular.font(size: 10))
                    .foregroundColor(badge.isEarned ? ColorPalette.gtGrey.color : lightGreyTextColor)
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing], 15)
            }
        }
    }
    
    @ViewBuilder private func badgeBackground(withShadow: Bool) -> some View {
        
        if withShadow {
            
            Color.white
                .cornerRadius(10)
                .shadow(
                    color: Color.black.opacity(0.15),
                    radius: 5,
                    x: 0,
                    y: 3
                )
            
        } else {
            
            Color.white
                .cornerRadius(10)
        }
    }
}
