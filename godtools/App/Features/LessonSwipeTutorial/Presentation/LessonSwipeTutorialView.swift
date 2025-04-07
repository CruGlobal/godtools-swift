//
//  LessonSwipeTutorialView.swift
//  godtools
//
//  Created by Rachael Skeath on 4/7/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct LessonSwipeTutorialView: View {
    
    private let topGradientColor = Color.getColorWithRGB(red: 12, green: 37, blue: 50, opacity: 1)
    private let bottomGradientColor = Color.getColorWithRGB(red: 17, green: 49, blue: 66, opacity: 0.75)
    
    var body: some View {
        
        ZStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [topGradientColor, bottomGradientColor]
                ),
                startPoint: .top,
                endPoint: .bottom
            )

            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LessonSwipeTutorialView()
}
