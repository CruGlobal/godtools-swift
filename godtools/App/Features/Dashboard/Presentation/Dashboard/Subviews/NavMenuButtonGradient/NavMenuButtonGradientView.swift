//
//  NavMenuButtonGradientView.swift
//  godtools
//
//  Created by Levi Eggert on 2/26/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct NavMenuButtonGradientView: View {
    
    private let menuButtonLeading: CGFloat
    private let menuButtonSize: CGFloat
    private let navHeight: CGFloat
    private let layoutDirection: LayoutDirection
    
    init(menuButtonLeading: CGFloat, menuButtonSize: CGFloat, navHeight: CGFloat, layoutDirection: LayoutDirection) {
     
        self.menuButtonLeading = menuButtonLeading
        self.menuButtonSize = menuButtonSize
        self.navHeight = navHeight
        self.layoutDirection = layoutDirection
    }
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            
            HStack(alignment: .top, spacing: 0) {
                
                Rectangle()
                    .fill(Color.white)
                    .frame(width: menuButtonLeading + menuButtonSize, height: navHeight)
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 14, height: navHeight)
                    .background(
                        getLinearGradient(layoutDirection: layoutDirection)
                    )
            }
        }
    }
    
    @ViewBuilder private func getLinearGradient(layoutDirection: LayoutDirection) -> some View {
                
        let colors: [Color] = [.white, .white.opacity(0.5), .white.opacity(0)]
        
        let gradientColors: [Color] = layoutDirection == .leftToRight ? colors : colors.reversed()

        LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
