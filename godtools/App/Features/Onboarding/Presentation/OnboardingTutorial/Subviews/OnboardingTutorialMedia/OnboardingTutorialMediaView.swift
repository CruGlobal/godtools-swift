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
    
    @ObservedObject var viewModel: OnboardingTutorialMediaViewModel
        
    let geometry: GeometryProxy
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
                        
            Text(viewModel.title)
                .multilineTextAlignment(.center)
                .foregroundColor(ColorPalette.gtBlue.color)
                .fixedSize(horizontal: false, vertical: true)
                .font(FontLibrary.sfProDisplayLight.font(size: 26))
                .padding(EdgeInsets(top: geometry.size.height * 0.1, leading: 30, bottom: 0, trailing: 30))
            
            Text(viewModel.message)
                .multilineTextAlignment(.center)
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextLight.font(size: 18))
                .padding(EdgeInsets(top: 16, leading: 30, bottom: 0, trailing: 30))
            
            Spacer()
            
            let animationWidth: CGFloat = geometry.size.width * 0.75
            let animationHeight: CGFloat = (animationWidth / animationAspectRatio.width) * animationAspectRatio.height
            
            AnimatedSwiftUIView(
                viewModel: viewModel.getAnimationViewModel(),
                contentMode: .scaleAspectFill
            )
            .frame(width: animationWidth, height: animationHeight)
            .padding(EdgeInsets(top: 0, leading: 30, bottom: 10, trailing: 30))
            
            Spacer()
        }
    }
}
