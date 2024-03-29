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
                    .foregroundColor(badge.textColor)
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing], 15)
            }
        }
    }
    
    @ViewBuilder private func badgeBackground(withShadow: Bool) -> some View {
        
        if withShadow {
            
            badgeBackground()
                .shadow(
                    color: Color.black.opacity(0.15),
                    radius: 5,
                    x: 0,
                    y: 3
                )
            
        } else {
            
            badgeBackground()
        }
    }
    
    @ViewBuilder private func badgeBackground() -> some View {
        
        Color.white
            .cornerRadius(10)
    }
}
