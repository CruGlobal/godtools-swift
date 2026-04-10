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

    private let title: String
    private let message: String
    private let changeSettingsButtonTitle: String
    private let goToAllLessonsButtonTitle: String
    private let geometry: GeometryProxy
    private let heightMultiplier: CGFloat
    private let changeSettingsAction: () -> Void
    private let goToAllLessonsAction: () -> Void

    init(title: String, message: String, changeSettingsButtonTitle: String, goToAllLessonsButtonTitle: String, geometry: GeometryProxy, heightMultiplier: CGFloat = 0.7, changeSettingsAction: @escaping () -> Void, goToAllLessonsAction: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.changeSettingsButtonTitle = changeSettingsButtonTitle
        self.goToAllLessonsButtonTitle = goToAllLessonsButtonTitle
        self.geometry = geometry
        self.heightMultiplier = heightMultiplier
        self.changeSettingsAction = changeSettingsAction
        self.goToAllLessonsAction = goToAllLessonsAction
    }

    var body: some View {

        ZStack {
            PersonalizationUnavailableView.backgroundColor

            VStack(alignment: .center, spacing: 0) {

                Spacer()

                Text(title)
                    .font(FontLibrary.sfProTextRegular.font(size: 18))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(FontLibrary.sfProTextRegular.font(size: 14))
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.top, 10)
                    .padding(.horizontal, 30)

                GTWhiteButton(
                    title: changeSettingsButtonTitle,
                    font: FontLibrary.sfProTextSemibold.font(size: 14),
                    width: 180,
                    height: 28,
                    cornerRadius: 20,
                    backgroundColor: .clear,
                    action: changeSettingsAction
                )
                .padding(.top, 20)

                GTBlueButton(
                    title: goToAllLessonsButtonTitle,
                    font: FontLibrary.sfProTextSemibold.font(size: 14),
                    width: 180,
                    height: 28,
                    cornerRadius: 20,
                    action: goToAllLessonsAction
                )
                .padding(.top, 10)

                Spacer()
            }
        }
        .frame(height: (geometry.size.height * heightMultiplier) - 15)
        .padding(.horizontal, DashboardView.contentHorizontalInsets)
    }
}
