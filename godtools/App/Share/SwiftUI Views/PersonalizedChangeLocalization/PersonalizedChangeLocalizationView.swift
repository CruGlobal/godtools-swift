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
    private let buttonTitle: String
    private let buttonAction: () -> Void
    private let onHeightChanged: (CGFloat) -> Void

    init(
        geometry: GeometryProxy,
        title: String,
        subtitle: String,
        buttonTitle: String,
        onHeightChanged: @escaping (CGFloat) -> Void = { _ in },
        buttonAction: @escaping () -> Void
    ) {
       
        self.geometry = geometry
        self.title = title
        self.subtitle = subtitle
        self.buttonTitle = buttonTitle
        self.onHeightChanged = onHeightChanged
        self.buttonAction = buttonAction
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
                title: buttonTitle,
                font: PersonalizationUnavailableView.buttonFont,
                titleHorizontalPadding: 24,
                titleVerticalPadding: 11,
                cornerRadius: PersonalizationUnavailableView.buttonCornerRadius,
                tapped: buttonAction
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
                    onHeightChanged(geometry.size.height)
                }
                .onChange(of: geometry.size.height) { newHeight in
                    onHeightChanged(newHeight)
                }
            }
        )
    }
}
