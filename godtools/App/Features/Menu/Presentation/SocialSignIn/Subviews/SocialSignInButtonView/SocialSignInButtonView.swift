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
        
        ZStack {
            
            viewModel.backgroundColor
                .ignoresSafeArea()
            
            HStack {
                
                Image(viewModel.iconName)
                
                Text(viewModel.buttonText)
                    .font(FontLibrary.sfProTextRegular.font(size: 12))
                    .foregroundColor(viewModel.fontColor)
            }
            
        }
        .frame(height: 43)
        .cornerRadius(6)
    }
}
