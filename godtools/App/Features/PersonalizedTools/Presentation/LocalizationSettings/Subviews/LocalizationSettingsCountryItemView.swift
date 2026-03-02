//
//  LocalizationSettingsCountryItemView.swift
//  godtools
//
//  Created by Rachael Skeath on 11/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct LocalizationSettingsCountryItemView: View {
    
    private static let lightGrey = Color.getColorWithRGB(red: 151, green: 151, blue: 151, opacity: 1)
    
    private let country: LocalizationSettingsCountryListItem
    private let isSelected: Bool
    private let tappedClosure: (() -> Void)?
    private let accessibility: AccessibilityStrings.Button = .localizationSettingsCountryListItem

    init(country: LocalizationSettingsCountryListItem, isSelected: Bool, tappedClosure: (() -> Void)?) {
        
        self.country = country
        self.isSelected = isSelected
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        Button {
            tappedClosure?()
            
        } label: {
            
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    
                    HStack(spacing: 10) {

                        Text(country.primaryText)
                            .font(FontLibrary.sfProTextRegular.font(size: 15))
                            .foregroundColor(ColorPalette.gtGrey.color)

                        Text(country.secondaryText)
                            .font(FontLibrary.sfProTextRegular.font(size: 15))
                            .foregroundColor(LocalizationSettingsCountryItemView.lightGrey)
                    }
                }
                .padding(.vertical, 3)
                
                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(ColorPalette.gtBlue.color)
                        .padding(.trailing, 5)
                }
            }
        }
        .accessibilityIdentifier(accessibility.id)
    }
}
