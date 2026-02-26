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
    
    init(menuButtonLeading: CGFloat, menuButtonSize: CGFloat) {
     
        self.menuButtonLeading = menuButtonLeading
        self.menuButtonSize = menuButtonSize
    }
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            
            HStack(alignment: .top, spacing: 0) {
                
                Rectangle()
                    .fill(Color.white)
                    .frame(width: menuButtonLeading + menuButtonSize, height: PersonalizedToolToggle.height)
                    .border(Color.red, width: 1)
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 40, height: PersonalizedToolToggle.height)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [.white, .white.opacity(0.5), .white.opacity(0)]), startPoint: .leading, endPoint: .trailing)
                    )
                    .border(Color.blue, width: 1)
            }
        }
    }
}
