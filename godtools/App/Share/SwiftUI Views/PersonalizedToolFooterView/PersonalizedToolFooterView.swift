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

    private let title: String
    private let subtitle: String
    private let buttonTitle: String
    private let buttonAction: () -> Void
    private let onHeightChanged: (CGFloat) -> Void

    init(title: String, subtitle: String, buttonTitle: String, onHeightChanged: @escaping (CGFloat) -> Void = { _ in }, buttonAction: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.buttonTitle = buttonTitle
        self.onHeightChanged = onHeightChanged
        self.buttonAction = buttonAction
    }
    
    var body: some View {

        VStack(alignment: .leading, spacing: 0) {

            Text(title)
                .font(FontLibrary.sfProDisplayRegular.font(size: 16))
                .foregroundColor(.black)
                .padding(.bottom, 2)

            Text(subtitle)
                .font(FontLibrary.sfProTextLight.font(size: 12))
                .foregroundColor(.black)
                .padding(.bottom, 15)

            HStack {
                Spacer()

                GTBlueButton(
                    title: buttonTitle,
                    fontSize: 14,
                    width: 147,
                    height: 28,
                    cornerRadius: 20,
                    action: buttonAction
                )

                Spacer()
            }
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
