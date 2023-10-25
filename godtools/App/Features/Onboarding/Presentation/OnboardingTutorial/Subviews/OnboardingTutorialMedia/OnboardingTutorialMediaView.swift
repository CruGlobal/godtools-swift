//
//  OnboardingTutorialMediaView.swift
//  godtools
//
//  Created by Levi Eggert on 2/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct OnboardingTutorialMediaView: View {
        
    private let animationAspectRatio: CGSize = CGSize(width: 154, height: 139)
    private let screenAccessibility: AccessibilityStrings.Screen
    
    @ObservedObject private var viewModel: OnboardingTutorialMediaViewModel
        
    let geometry: GeometryProxy
    
    init(viewModel: OnboardingTutorialMediaViewModel, geometry: GeometryProxy, screenAccessibility: AccessibilityStrings.Screen) {
        
        self.viewModel = viewModel
        self.geometry = geometry
        self.screenAccessibility = screenAccessibility
    }
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
                    
            AccessibilityScreenElementView(screenAccessibility: screenAccessibility)
            
            Text(viewModel.title)
                .multilineTextAlignment(.center)
                .foregroundColor(ColorPalette.gtBlue.color)
                .fixedSize(horizontal: false, vertical: true)
                .font(FontLibrary.sfProDisplayLight.font(size: 27))
                .padding(EdgeInsets(top: geometry.size.height * 0.1, leading: 30, bottom: 0, trailing: 30))
            
            Text(viewModel.message)
                .multilineTextAlignment(.center)
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextLight.font(size: 17))
                .padding(EdgeInsets(top: 16, leading: 30, bottom: 0, trailing: 30))
            
            Spacer()
            
            let animationWidth: CGFloat = geometry.size.width * 0.75
            let animationHeight: CGFloat = (animationWidth / animationAspectRatio.width) * animationAspectRatio.height
            
            AnimatedSwiftUIView(
                viewModel: viewModel.getAnimationViewModel(),
                contentMode: .scaleAspectFill
            )
            .frame(width: animationWidth, height: animationHeight)
            .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
            
            FixedVerticalSpacer(height: 20)
            
            Spacer()
        }
    }
}
