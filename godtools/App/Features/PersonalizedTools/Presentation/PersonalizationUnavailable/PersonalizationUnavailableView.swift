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
    
    static let buttonHeight: CGFloat = 38
    static let buttonWidthMultiplier: CGFloat = 0.8
    static let buttonCornerRadius: CGFloat = 20
    static let buttonFont: Font = FontLibrary.sfProTextSemibold.font(size: 14)

    private let buttonWidth: CGFloat
    private let title: String
    private let message: String
    private let changeSettingsButtonTitle: String
    private let goToAllLessonsButtonTitle: String
    private let geometry: GeometryProxy
    private let heightMultiplier: CGFloat
    private let changeSettingsAction: () -> Void
    private let goToAllLessonsAction: () -> Void

    init(title: String, message: String, changeSettingsButtonTitle: String, goToAllLessonsButtonTitle: String, geometry: GeometryProxy, heightMultiplier: CGFloat = 0.7, changeSettingsAction: @escaping () -> Void, goToAllLessonsAction: @escaping () -> Void) {
        
        buttonWidth = geometry.size.width * PersonalizationUnavailableView.buttonWidthMultiplier
        
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

                GTButton(
                    style: .white,
                    title: changeSettingsButtonTitle,
                    color: .clear,
                    font: Self.buttonFont,
                    width: buttonWidth,
                    height: Self.buttonHeight,
                    cornerRadius: Self.buttonCornerRadius,
                    tapped: changeSettingsAction
                )
                .padding(.top, 20)

                GTButton(
                    style: .blue,
                    title: goToAllLessonsButtonTitle,
                    font: Self.buttonFont,
                    width: buttonWidth,
                    height: Self.buttonHeight,
                    cornerRadius: Self.buttonCornerRadius,
                    tapped: goToAllLessonsAction
                )
                .padding(.top, 10)

                Spacer()
            }
        }
        .frame(height: (geometry.size.height * heightMultiplier) - 15)
        .padding(.horizontal, DashboardView.contentHorizontalInsets)
    }
}
