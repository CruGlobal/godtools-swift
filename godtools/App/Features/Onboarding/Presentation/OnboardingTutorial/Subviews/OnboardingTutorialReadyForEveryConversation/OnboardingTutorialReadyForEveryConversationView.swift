//
//  OnboardingTutorialReadyForEveryConversationView.swift
//  godtools
//
//  Created by Levi Eggert on 2/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct OnboardingTutorialReadyForEveryConversationView: View {
    
    private let logoAspectRatio: CGSize = CGSize(width: 221, height: 131)
    
    @ObservedObject private var viewModel: OnboardingTutorialReadyForEveryConversationViewModel
    
    let geometry: GeometryProxy
    let watchVideoTappedClosure: (() -> Void)
    
    init(viewModel: OnboardingTutorialReadyForEveryConversationViewModel, geometry: GeometryProxy, watchVideoTappedClosure: @escaping (() -> Void)) {
        
        self.viewModel = viewModel
        self.geometry = geometry
        self.watchVideoTappedClosure = watchVideoTappedClosure
    }
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
            
            Spacer()
            
            let logoWidth: CGFloat = geometry.size.width * 0.7
            let logoHeight: CGFloat = (logoWidth / logoAspectRatio.width) * logoAspectRatio.height
            
            ImageCatalog.onboardingWelcomeLogo.image
                .resizable()
                .scaledToFit()
                .frame(width: logoWidth, height: logoHeight)
                .clipped()
                        
            Text(viewModel.title)
                .multilineTextAlignment(.center)
                .foregroundColor(ColorPalette.gtBlue.color)
                .font(FontLibrary.sfProDisplayLight.font(size: 31))
                .padding(EdgeInsets(top: 40, leading: 30, bottom: 30, trailing: 30))
                        
            Button(action: {
                watchVideoTappedClosure()
            }) {
                
                HStack(alignment: .center, spacing: 8) {
                    
                    Text(viewModel.watchVideoButtonTitle)
                        .foregroundColor(ColorPalette.gtBlue.color)
                        .font(FontLibrary.sfProTextBold.font(size: 16))
                    
                    ImageCatalog.playIcon.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .clipped()
                }
                .frame(width: geometry.size.width, height: 50, alignment: .center)
            }
            .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
            
            Spacer()
        }
    }
}
