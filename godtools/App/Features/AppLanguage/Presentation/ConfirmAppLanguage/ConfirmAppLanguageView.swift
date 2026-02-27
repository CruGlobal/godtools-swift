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
            
            AccessibilityScreenElementView(screenAccessibility: .confirmAppLanguage)
            
            VStack(alignment: .leading, spacing: 16) {
                
                HStack {
                    Spacer()
                    
                    CloseButton {
                        viewModel.closeTapped()
                    }
                }
                .padding(.top, 20)
                
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
                    attributedMessageView(attributedString: getAttributedMessageString(highlightStringDomainModel: viewModel.strings.messageInCurrentLanguageHighlightModel), fontSize: 18)
                    
                    attributedMessageView(attributedString: getAttributedMessageString(highlightStringDomainModel: viewModel.strings.messageInNewlySelectedLanguageHighlightModel), fontSize: 18)
                }
                .padding(.horizontal, 10)
                
                FixedVerticalSpacer(height: 20)
                
                let buttonSpacing: CGFloat = 12

                HStack(spacing: buttonSpacing) {
                    
                    let buttonWidth = (geometry.size.width - buttonSpacing - 2 * horizontalPadding) / 2
                    
                    GTWhiteButton(title: viewModel.strings.nevermindButtonText, fontSize: 15, width: buttonWidth, height: 48) {
                        
                        viewModel.nevermindButtonTapped()
                    }
                    
                    GTBlueButton(title: viewModel.strings.changeLanguageButtonText, fontSize: 15, width: buttonWidth, height: 48) {
                        
                        viewModel.confirmLanguageButtonTapped()
                    }
                }
                
                Spacer()
                Spacer()
                
            }
            .padding(.horizontal, horizontalPadding)
        }
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
    
    @ViewBuilder func attributedMessageView(attributedString: AttributedString, fontSize: CGFloat) -> some View {
        
        Text(attributedString)
            .font(FontLibrary.sfProTextRegular.font(size: fontSize))
            .foregroundColor(ColorPalette.gtGrey.color)
    }
    
    private func getAttributedMessageString(highlightStringDomainModel: ConfirmAppLanguageHighlightStringDomainModel) -> AttributedString {
        
        var attributedString = AttributedString(highlightStringDomainModel.fullText)
        
        guard let range = attributedString.range(of: highlightStringDomainModel.highlightText) else { return attributedString }
        attributedString[range].foregroundColor = ColorPalette.gtBlue.color
        
        return attributedString
    }
}
