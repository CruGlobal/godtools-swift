//
//  PersonalizedToolsCountryItemView.swift
//  godtools
//
//  Created by Rachael Skeath on 11/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct PersonalizedToolsCountryItemView: View {
    
    private static let lightGrey = Color.getColorWithRGB(red: 151, green: 151, blue: 151, opacity: 1)
    
    private let country: PersonalizedToolsCountryDomainModel
    private let tappedClosure: (() -> Void)?
    private let accessibility: AccessibilityStrings.Button = .personalizedToolCountryListItem
    
    init(country: PersonalizedToolsCountryDomainModel, tappedClosure: (() -> Void)?) {
        
        self.country = country
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        Button {
            tappedClosure?()
            
        } label: {
            
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    
                    HStack(spacing: 10) {
                        
                        Text(country.countryNameTranslatedInOwnLanguage)
                            .font(FontLibrary.sfProTextRegular.font(size: 15))
                            .foregroundColor(ColorPalette.gtGrey.color)
                        
                        Text(country.countryNameTranslatedInCurrentAppLanguage)
                            .font(FontLibrary.sfProTextRegular.font(size: 15))
                            .foregroundColor(PersonalizedToolsCountryItemView.lightGrey)
                    }
                }
                .padding(.vertical, 3)
                
                Spacer()
            }
        }
        .accessibilityIdentifier(accessibility.id)
    }
}
