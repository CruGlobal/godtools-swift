//
//  OnboardingTutorialMediaView.swift
//  godtools
//
//  Created by Levi Eggert on 2/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct OnboardingTutorialMediaView: View {
        
    @ObservedObject var viewModel: OnboardingTutorialMediaViewModel
        
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
                        
            Text(viewModel.title)
                .multilineTextAlignment(.center)
                .foregroundColor(ColorPalette.gtBlue.color)
                .font(FontLibrary.sfProDisplayLight.font(size: 26))
                .padding(EdgeInsets(top: 20, leading: 30, bottom: 15, trailing: 30))
            
            Text(viewModel.message)
                .multilineTextAlignment(.center)
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextLight.font(size: 18))
                .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
            
            AnimatedSwiftUIView(
                viewModel: viewModel.getAnimationViewModel(),
                contentMode: .scaleAspectFill
            )
        }
    }
}
