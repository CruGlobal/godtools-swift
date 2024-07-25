//
//  SocialSignInView.swift
//  godtools
//
//  Created by Rachael Skeath on 4/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct SocialSignInView: View {
    
    private let backgroundColor: Color
    private let screenAccessibility: AccessibilityStrings.Screen
    
    @ObservedObject private var viewModel: SocialSignInViewModel
    
    init(viewModel: SocialSignInViewModel, backgroundColor: Color, screenAccessibility: AccessibilityStrings.Screen) {
        
        self.viewModel = viewModel
        self.backgroundColor = backgroundColor
        self.screenAccessibility = screenAccessibility
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            AccessibilityScreenElementView(screenAccessibility: screenAccessibility)
            
            ZStack(alignment: .top) {
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(alignment: .trailing) {
                    
                    Spacer()
                    
                    Image(ImageCatalog.loginBackground.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Text(viewModel.title)
                            .font(FontLibrary.sfProTextRegular.font(size: 40))
                            .foregroundColor(.white)
                        
                        Text(viewModel.subtitle)
                            .font(FontLibrary.sfProTextRegular.font(size: 16))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        FixedVerticalSpacer(height: 10)
                        
                        VStack(spacing: 10) {
                            
                            SocialSignInButtonView(buttonType: .google, title: viewModel.signInWithGoogleButtonTitle) {
                                viewModel.signInWithGoogleTapped()
                            }
                            
                            SocialSignInButtonView(buttonType: .facebook, title: viewModel.signInWithFacebookButtonTitle) {
                                viewModel.signInWithFacebookTapped()
                            }
                            
                            SocialSignInButtonView(buttonType: .apple, title: viewModel.signInWithAppleButtonTitle) {
                                viewModel.signInWithAppleTapped()
                            }
                        }
                        
                    }
                    .padding([.leading, .trailing], 36)
                    .padding(.bottom, 35)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}
