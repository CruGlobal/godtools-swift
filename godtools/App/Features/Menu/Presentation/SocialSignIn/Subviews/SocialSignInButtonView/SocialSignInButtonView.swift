//
//  SocialSignInButtonView.swift
//  godtools
//
//  Created by Rachael Skeath on 4/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct SocialSignInButtonView: View {
    
    @ObservedObject var viewModel: SocialSignInButtonViewModel
    
    var body: some View {
        
        Button {
            
            viewModel.loginTapped()
            
        } label: {
            
            ZStack {
                
                viewModel.backgroundColor
                    .ignoresSafeArea()
                
                HStack(spacing: 12) {
                    
                    Image(viewModel.iconName)
                        .frame(width: viewModel.iconSize.width, height: viewModel.iconSize.height)
                    
                    Text(viewModel.buttonText)
                        .font(viewModel.font)
                        .foregroundColor(viewModel.fontColor)
                }
                
            }
            .frame(height: 43)
            .cornerRadius(6)
        }

    }
}
