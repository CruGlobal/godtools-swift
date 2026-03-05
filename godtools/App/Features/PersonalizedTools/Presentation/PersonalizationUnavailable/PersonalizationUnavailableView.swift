//
//  PersonalizationUnavailableView.swift
//  godtools
//
//  Created by Rachael Skeath on 3/4/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct PersonalizationUnavailableView: View {

    private static let backgroundColor = Color.getColorWithRGB(red: 245, green: 245, blue: 245, opacity: 1)
    private static let iconBackgroundColor = Color.getColorWithRGB(red: 100, green: 100, blue: 100, opacity: 1)

    private let title: String
    private let message: String
    private let buttonTitle: String
    private let buttonAction: () -> Void

    init(title: String, message: String, buttonTitle: String, buttonAction: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }

    var body: some View {

        VStack(alignment: .center, spacing: 0) {

            // Exclamation mark icon
            ZStack {
                Circle()
                    .fill(PersonalizationUnavailableView.iconBackgroundColor)
                    .frame(width: 60, height: 60)

                Text("!")
                    .font(FontLibrary.sfProTextBold.font(size: 40))
                    .foregroundColor(.white)
            }
            .padding(.top, 30)

            // Title
            Text(title)
                .font(FontLibrary.sfProTextBold.font(size: 20))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.top, 20)

            // Message
            Text(message)
                .font(FontLibrary.sfProTextRegular.font(size: 16))
                .foregroundColor(ColorPalette.gtGrey.color)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 10)
                .padding(.horizontal, 20)

            // Button
            GTBlueButton(
                title: buttonTitle,
                font: FontLibrary.sfProTextSemibold.font(size: 16),
                width: 200,
                height: 44,
                cornerRadius: 22,
                action: buttonAction
            )
            .padding(.top, 25)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity)
        .background(PersonalizationUnavailableView.backgroundColor)
        .cornerRadius(8)
        .padding(.horizontal, DashboardView.contentHorizontalInsets)
    }
}
