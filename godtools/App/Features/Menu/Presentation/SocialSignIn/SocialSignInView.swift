//
//  SocialSignInView.swift
//  godtools
//
//  Created by Rachael Skeath on 4/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct SocialSignInView: View {
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
                        
                        Text("Sign in")
                            .font(FontLibrary.sfProTextRegular.font(size: 40))
                            .foregroundColor(.white)
                        
                        Text("Create an account to have real stories, encouragement, and practical tips at your fingertips.")
                            .font(FontLibrary.sfProTextRegular.font(size: 16))
                            .foregroundColor(.white)
                        
                        FixedVerticalSpacer(height: 10)
                        
                        VStack(spacing: 10) {
                            
                            SocialSignInButtonView(viewModel: SocialSignInButtonViewModel(buttonType: .google))
                            SocialSignInButtonView(viewModel: SocialSignInButtonViewModel(buttonType: .facebook))
                            SocialSignInButtonView(viewModel: SocialSignInButtonViewModel(buttonType: .apple))
                        }
                        
                    }
                    .padding([.leading, .trailing], 36)
                }
                
            }
            
        }
        
    }
}

struct SocialSignInView_Previews: PreviewProvider {
    static var previews: some View {
        SocialSignInView()
            .previewLayout(.device)
    }
}
