//
//  PersonalizedChangeLocalizationView.swift
//  godtools
//
//  Created by Rachael Skeath on 1/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct PersonalizedChangeLocalizationView: View {

    private static let lightBlue = Color.getColorWithRGB(red: 223, green: 240, blue: 249, opacity: 1)
    
    private let geometry: GeometryProxy
    private let title: String
    private let subtitle: String
    private let changeLocalizationSettingsAction: String
    private let changeLocalizationSettingsTapped: (() -> Void)?
    private let onHeightChanged: ((CGFloat) -> Void)?

    init(
        geometry: GeometryProxy,
        title: String,
        subtitle: String,
        changeLocalizationSettingsAction: String,
        changeLocalizationSettingsTapped: (() -> Void)?,
        onHeightChanged: ((CGFloat) -> Void)? = nil
    ) {
       
        self.geometry = geometry
        self.title = title
        self.subtitle = subtitle
        self.changeLocalizationSettingsAction = changeLocalizationSettingsAction
        self.changeLocalizationSettingsTapped = changeLocalizationSettingsTapped
        self.onHeightChanged = onHeightChanged
    }
    
    var body: some View {

        VStack(alignment: .leading, spacing: 0) {

            Text(title)
                .font(FontLibrary.sfProTextSemibold.font(size: 18))
                .foregroundColor(.black)

            Text(subtitle)
                .font(FontLibrary.sfProTextRegular.font(size: 14))
                .foregroundColor(.black)
                .padding(.top, 5)

            GTButton(
                style: .blue,
                title: changeLocalizationSettingsAction,
                font: PersonalizationUnavailableView.buttonFont,
                titleHorizontalPadding: PersonalizationUnavailableView.buttonTitleHorizontalPadding,
                titleVerticalPadding: PersonalizationUnavailableView.buttonTitleVerticalPadding,
                cornerRadius: PersonalizationUnavailableView.buttonCornerRadius,
                tapped: changeLocalizationSettingsTapped
            )
            .padding(.top, 20)
            .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 30)
        .padding(.vertical, 27)
        .background(Self.lightBlue)
        .background(
            GeometryReader { geometry in
                Color.clear.onAppear {
                    onHeightChanged?(geometry.size.height)
                }
                .onChange(of: geometry.size.height) { newHeight in
                    onHeightChanged?(newHeight)
                }
            }
        )
    }
}
