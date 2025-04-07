//
//  LessonSwipeTutorialView.swift
//  godtools
//
//  Created by Rachael Skeath on 4/7/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI
import Lottie

struct LessonSwipeTutorialView: View {
    
    private let topGradientColor = Color.getColorWithRGB(red: 12, green: 37, blue: 50, opacity: 1)
    private let bottomGradientColor = Color.getColorWithRGB(red: 17, green: 49, blue: 66, opacity: 0.75)
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                
                LinearGradient(
                    gradient: Gradient(
                        colors: [topGradientColor, bottomGradientColor]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                VStack {
                    
                    Spacer()
                    
                    Text("Swipe to change pages")
                        .font(FontLibrary.sfProDisplayRegular.font(size: 30))
                        .foregroundStyle(.white)
                    
                    let buttonWidth = geometry.size.width * 194/375
                    let lottieWidth = buttonWidth * 1.5
                    let lottieHeightRatio: CGFloat = 243/191
                    
                    LottieView(animation: .named(getLottieAnimationFileName()))
                        .looping()
                        .frame(width: lottieWidth, height: lottieHeightRatio * lottieWidth)
                    
                    GTBlueButton(title: "Got it", fontSize: 16, width: buttonWidth, height: 47, cornerRadius: 30) {
                        
                        
                    }
                    
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
    
    private func getLottieAnimationFileName() -> String {
        if ApplicationLayout.shared.layoutDirection == .rightToLeft {
            return "lesson_tutorial_page_swipe-RTL"
        } else {
            return "lesson_tutorial_page_swipe-LTR"
        }
    }
}

#Preview {
    LessonSwipeTutorialView()
}
