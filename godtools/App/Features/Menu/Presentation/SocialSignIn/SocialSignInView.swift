//
//  SocialSignInView.swift
//  godtools
//
//  Created by Rachael Skeath on 4/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct SocialSignInView: View {
    
    @ObservedObject var viewModel: SocialSignInViewModel
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack {
                ColorPalette.gtBlue.color
                    .ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    
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
                            
                            SocialSignInButtonView(viewModel: viewModel.googleSignInButtonViewModel)
                            SocialSignInButtonView(viewModel: viewModel.facebookSignInButtonViewModel)
                            SocialSignInButtonView(viewModel: viewModel.appleSignInButtonViewModel)
                        }
                        
                    }
                    .padding([.leading, .trailing], 36)
                }
            }
        }
    }
}
