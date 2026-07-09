//
//  LocalizationSettingsConfirmationView.swift
//  godtools
//
//  Created by Rachael Skeath on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct LocalizationSettingsConfirmationView: View {

    private let cardHorizontalPadding: CGFloat = 25
    private let contentHorizontalPadding: CGFloat = 20
    private let buttonSpacing: CGFloat = 10
    private let buttonFontSize: CGFloat = 15
    private let buttonHeight: CGFloat = 50

    @ObservedObject private var viewModel: LocalizationSettingsConfirmationViewModel

    @State private var isVisible: Bool = false

    init(viewModel: LocalizationSettingsConfirmationViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {

        GeometryReader { geometry in
            
            AccessibilityScreenElementView(screenAccessibility: .confirmLocalizationSettings)
            
            FullScreenOverlayView(
                color: Color.black.opacity(0.3),
                tappedClosure: {
                    viewModel.closeTapped()
                }
            )
            
            let screenWidth: CGFloat = geometry.size.width
            let maxScreenWidth: CGFloat = 450
            let cardWidth: CGFloat = min(screenWidth, maxScreenWidth) - (cardHorizontalPadding * 2)
            let buttonWidth: CGFloat = cardWidth - buttonSpacing - (contentHorizontalPadding * 2)
            
            ZStack(alignment: .topLeading) {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        ImageCatalog.localizationSettingsGlobe.image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 59, height: 67)
                            .frame(maxWidth: .infinity)

                        Text(getAttributedTitleString())
                            .font(FontLibrary.sfProTextRegular.font(size: 18))
                            .foregroundColor(ColorPalette.gtGrey.color)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 15)

                        Text(viewModel.strings.description)
                            .font(FontLibrary.sfProTextRegular.font(size: 18))
                            .foregroundColor(ColorPalette.gtGrey.color)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 12)

                        Text(viewModel.strings.detail)
                            .font(FontLibrary.sfProTextRegular.font(size: 15))
                            .foregroundColor(ColorPalette.gtGrey.color)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 10)
                    }
                    .padding(.top, 25)
                    .padding([.horizontal], contentHorizontalPadding)
                    
                    VStack(alignment: .center, spacing: buttonSpacing) {

                        GTButton(
                            style: .white,
                            title: viewModel.strings.cancelButton,
                            fontSize: buttonFontSize,
                            width: buttonWidth,
                            height: buttonHeight,
                            accessibility: AccessibilityStrings.Button.editLocalization,
                            tapped: {
                                viewModel.cancelTapped()
                            }
                        )

                        GTButton(
                            style: .blue,
                            title: viewModel.strings.confirmButton,
                            fontSize: buttonFontSize,
                            width: buttonWidth,
                            height: buttonHeight,
                            accessibility: AccessibilityStrings.Button.continueForward,
                            tapped: {
                                viewModel.confirmTapped()
                            }
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 30)
                    .padding(.bottom, 24)
                }
                
                HStack(alignment: .center, spacing: 0, content: {
                    
                    Spacer()
                    
                    CloseButton(buttonSize: 44) {
                        viewModel.closeTapped()
                    }
                    .padding(.top, 10)
                    .padding(.trailing, 8)
                })
            }
            .frame(width: cardWidth)
            .background(Color.white)
            .cornerRadius(6)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.9)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isVisible)
        }
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }

    private func getAttributedTitleString() -> AttributedString {

        return AttributedString.withHighlightedText(
            fullText: viewModel.strings.titleHighlightModel.fullText,
            highlightText: viewModel.strings.titleHighlightModel.highlightText,
            highlightColor: ColorPalette.gtBlue.color
        )
    }
}
