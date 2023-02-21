//
//  OnboardingTutorialReadyForEveryConversationView.swift
//  godtools
//
//  Created by Levi Eggert on 2/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct OnboardingTutorialReadyForEveryConversationView: View {
    
    @ObservedObject var viewModel: OnboardingTutorialReadyForEveryConversationViewModel
    
    let geometry: GeometryProxy
    let watchVideoTappedClosure: (() -> Void)
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
            
            Spacer()
            
            ImageCatalog.onboardingWelcomeLogo.image
                .resizable()
                .scaledToFit()
                .frame(width: 221, height: 131)
                .clipped()
            
            FixedVerticalSpacer(height: 40)
            
            Text(viewModel.title)
                .multilineTextAlignment(.center)
                .foregroundColor(ColorPalette.gtBlue.color)
                .font(FontLibrary.sfProDisplayLight.font(size: 30))
                .padding(EdgeInsets(top: 0, leading: 30, bottom: 40, trailing: 30))
                        
            Button(action: {
                watchVideoTappedClosure()
            }) {
                
                HStack(alignment: .center, spacing: 8) {
                    
                    Text(viewModel.watchVideoButtonTitle)
                        .foregroundColor(ColorPalette.gtBlue.color)
                        .font(FontLibrary.sfProTextBold.font(size: 15))
                    
                    ImageCatalog.playIcon.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .clipped()
                }
                .frame(width: geometry.size.width, height: 50, alignment: .center)
            }
            .padding(EdgeInsets(top: 0, leading: 30, bottom: 40, trailing: 30))
        }
    }
}
