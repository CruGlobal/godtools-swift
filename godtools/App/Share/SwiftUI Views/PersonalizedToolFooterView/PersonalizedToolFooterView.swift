//
//  PersonalizedToolFooterView.swift
//  godtools
//
//  Created by Rachael Skeath on 1/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct PersonalizedToolFooterView: View {

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

            HStack {
                Spacer()

                GTButton(
                    style: .blue,
                    title: buttonTitle,
                    font: PersonalizationUnavailableView.buttonFont,
                    width: geometry.size.width * PersonalizationUnavailableView.buttonWidthMultiplier,
                    height: PersonalizationUnavailableView.buttonHeight,
                    cornerRadius: PersonalizationUnavailableView.buttonCornerRadius,
                    tapped: buttonAction
                )

                Spacer()
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 30)
        .padding(.vertical, 27)
        .background(PersonalizedToolFooterView.lightBlue)
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
