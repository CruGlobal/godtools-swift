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
    
    @ObservedObject private var viewModel: SocialSignInViewModel
    
    init(viewModel: SocialSignInViewModel, backgroundColor: Color) {
        
        self.viewModel = viewModel
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack(alignment: .top) {
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(alignment: .trailing) {
                    
                    FixedVerticalSpacer(height: 22)
                    
                    Image(ImageCatalog.loginBackground.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Text(viewModel.titleText)
                            .font(FontLibrary.sfProTextRegular.font(size: 40))
                            .foregroundColor(.white)
                        
                        Text(viewModel.subtitleText)
                            .font(FontLibrary.sfProTextRegular.font(size: 16))
                            .foregroundColor(.white)
                        
                        FixedVerticalSpacer(height: 10)
                        
                        VStack(spacing: 10) {
                            
                            SocialSignInButtonView(viewModel: viewModel.googleSignInButtonViewModel, tappedClosure: {
                                viewModel.signInWithGoogleTapped()
                            })
                            
                            SocialSignInButtonView(viewModel: viewModel.facebookSignInButtonViewModel, tappedClosure: {
                                viewModel.signInWithFacebookTapped()
                            })
                            
                            SocialSignInButtonView(viewModel: viewModel.appleSignInButtonViewModel, tappedClosure: {
                                viewModel.signInWithAppleTapped()
                            })
                        }
                        
                    }
                    .padding([.leading, .trailing], 36)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
