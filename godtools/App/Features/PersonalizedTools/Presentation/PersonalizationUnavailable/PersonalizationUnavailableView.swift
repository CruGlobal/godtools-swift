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
    
    static let buttonTitleHorizontalPadding: CGFloat = 24
    static let buttonTitleVerticalPadding: CGFloat = 11
    static let buttonCornerRadius: CGFloat = 20
    static let buttonFont: Font = FontLibrary.sfProTextSemibold.font(size: 14)

    private let title: String
    private let message: String
    private let changeSettingsButtonTitle: String
    private let goToAllToolsButtonTitle: String
    private let changeLocalizationSettingsTapped: (() -> Void)?
    private let goToAllToolsTapped: (() -> Void)?
    
    @State private var changeLocalizationSettingsButtonWidth: CGFloat?
    @State private var goToAllToolsButtonWidth: CGFloat?
    @State private var maxButtonWidth: CGFloat?

    init(
        title: String,
        message: String,
        changeSettingsButtonTitle: String,
        goToAllToolsButtonTitle: String,
        changeLocalizationSettingsTapped: (() -> Void)?,
        goToAllToolsTapped: (() -> Void)?
    ) {
                
        self.title = title
        self.message = message
        self.changeSettingsButtonTitle = changeSettingsButtonTitle
        self.goToAllToolsButtonTitle = goToAllToolsButtonTitle
        self.changeLocalizationSettingsTapped = changeLocalizationSettingsTapped
        self.goToAllToolsTapped = goToAllToolsTapped
    }

    var body: some View {

        VStack(alignment: .center, spacing: 0) {

            Text(title)
                .font(FontLibrary.sfProTextRegular.font(size: 19))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)

            Text(message)
                .font(FontLibrary.sfProTextRegular.font(size: 15))
                .foregroundColor(ColorPalette.gtGrey.color)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 10)
                .padding(.horizontal, 30)
            
            VStack(alignment: .center, spacing: 10) {
                
                GTButton(
                    style: .white,
                    title: changeSettingsButtonTitle,
                    color: .clear,
                    font: Self.buttonFont,
                    width: maxButtonWidth,
                    titleHorizontalPadding: Self.buttonTitleHorizontalPadding,
                    titleVerticalPadding: Self.buttonTitleVerticalPadding,
                    cornerRadius: Self.buttonCornerRadius,
                    tapped: changeLocalizationSettingsTapped,
                    onTextWidthChanged: { (width: CGFloat) in
                        changeLocalizationSettingsButtonWidth = width
                        updateMaxButtonWidth()
                    }
                )

                GTButton(
                    style: .blue,
                    title: goToAllToolsButtonTitle,
                    font: Self.buttonFont,
                    width: maxButtonWidth,
                    titleHorizontalPadding: Self.buttonTitleHorizontalPadding,
                    titleVerticalPadding: Self.buttonTitleVerticalPadding,
                    cornerRadius: Self.buttonCornerRadius,
                    tapped: goToAllToolsTapped,
                    onTextWidthChanged: { (width: CGFloat) in
                        goToAllToolsButtonWidth = width
                        updateMaxButtonWidth()
                    }
                )
            }
            .padding(.top, 20)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 110)
        .background(PersonalizationUnavailableView.backgroundColor)
    }
    
    private func updateMaxButtonWidth() {
        
        guard let changeLocalizationSettingsButtonWidth = self.changeLocalizationSettingsButtonWidth,
              let goToAllToolsButtonWidth = self.goToAllToolsButtonWidth,
              changeLocalizationSettingsButtonWidth > 0 && goToAllToolsButtonWidth > 0 else {
                        
            maxButtonWidth = nil
            
            return
        }
        
        if changeLocalizationSettingsButtonWidth > goToAllToolsButtonWidth {
            maxButtonWidth = changeLocalizationSettingsButtonWidth
        }
        else {
            maxButtonWidth = goToAllToolsButtonWidth
        }
    }
}
