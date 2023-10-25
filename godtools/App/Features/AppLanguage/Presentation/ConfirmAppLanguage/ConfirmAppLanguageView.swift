//
//  ConfirmAppLanguageView.swift
//  godtools
//
//  Created by Rachael Skeath on 10/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ConfirmAppLanguageView: View {
    
    @ObservedObject private var viewModel: ConfirmAppLanguageViewModel
    
    init(viewModel: ConfirmAppLanguageViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        let horizontalPadding: CGFloat = 20
        
        GeometryReader { geometry in
            
            VStack(alignment: .leading, spacing: 16) {
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    ImageCatalog.languageSettingsLogo.image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 54, height: 54)
                    
                    Spacer()
                }
                
                FixedVerticalSpacer(height: 10)
                
                Group {
                    Text(viewModel.confirmLanguageText)
                        .font(FontLibrary.sfProTextRegular.font(size: 18))
                        .foregroundColor(ColorPalette.gtGrey.color)
                                        
                    Text(viewModel.translatedConfirmLanguageText)
                        .font(FontLibrary.sfProTextRegular.font(size: 14))
                        .foregroundColor(ColorPalette.gtGrey.color)
                }
                .padding(.horizontal, 10)
                
                FixedVerticalSpacer(height: 20)
                
                let buttonSpacing: CGFloat = 12

                HStack(spacing: buttonSpacing) {
                    
                    let buttonWidth = (geometry.size.width - buttonSpacing - 2*horizontalPadding) / 2
                    
                    GTBlueButton(title: viewModel.changeLanguageButtonTitle, fontSize: 15, width: buttonWidth, height: 48) {
                        
                        viewModel.confirmLanguageButtonTapped()
                    }
                    
                    GTWhiteButton(title: viewModel.nevermindButtonTitle, fontSize: 15, width: buttonWidth, height: 48) {
                        
                        viewModel.nevermindButtonTapped()
                    }
                }
                
                Spacer()
                Spacer()
                
            }
            .padding(.horizontal, horizontalPadding)
        }
    }
}
