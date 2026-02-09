//
//  LocalizationSettingsConfirmationView.swift
//  godtools
//
//  Created by Rachael Skeath on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct LocalizationSettingsConfirmationView: View {

    private let cardHorizontalPadding: CGFloat = 26
    private let buttonSpacing: CGFloat = 10

    @ObservedObject private var viewModel: LocalizationSettingsConfirmationViewModel

    @State private var isVisible: Bool = false

    init(viewModel: LocalizationSettingsConfirmationViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {

        ZStack {

            FullScreenOverlayView(tappedClosure: {
                viewModel.closeTapped()
            })
            .opacity(isVisible ? 1 : 0)
            .animation(.easeOut(duration: 0.3), value: isVisible)

            GeometryReader { geometry in

                let cardWidth: CGFloat = min(geometry.size.width - (cardHorizontalPadding * 2), 400)
                let buttonWidth: CGFloat = (cardWidth - (cardHorizontalPadding * 2) - buttonSpacing) / 2

                ZStack(alignment: .topTrailing) {

                    VStack(alignment: .leading, spacing: 0) {

                        VStack(alignment: .leading, spacing: 0) {

                            ImageCatalog.localizationSettingsGlobe.image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 59, height: 67)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 25)

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

                            HStack(spacing: buttonSpacing) {

                                GTWhiteButton(
                                    title: viewModel.strings.cancelButton,
                                    fontSize: 15,
                                    width: buttonWidth,
                                    height: 50,
                                    action: {
                                        viewModel.cancelTapped()
                                    }
                                )

                                GTBlueButton(
                                    title: viewModel.strings.confirmButton,
                                    fontSize: 15,
                                    width: buttonWidth,
                                    height: 50,
                                    action: {
                                        viewModel.confirmTapped()
                                    }
                                )
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 30)
                        }
                        .padding(.horizontal, cardHorizontalPadding)
                        .padding(.bottom, 28)
                    }
                    .background(Color.white)
                    .cornerRadius(6)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)

                    CloseButton(buttonSize: 44) {
                        viewModel.closeTapped()
                    }
                    .padding(.top, 10)
                    .padding(.trailing, 8)
                }
                .frame(width: cardWidth)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .opacity(isVisible ? 1 : 0)
                .scaleEffect(isVisible ? 1 : 0.9)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isVisible)
            }
        }
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }

    private func getAttributedTitleString() -> AttributedString {

        var attributedString = AttributedString(viewModel.strings.titleHighlightModel.fullText)

        guard let range = attributedString.range(of: viewModel.strings.titleHighlightModel.highlightText) else { return attributedString }
        attributedString[range].foregroundColor = ColorPalette.gtBlue.color

        return attributedString
    }
}
