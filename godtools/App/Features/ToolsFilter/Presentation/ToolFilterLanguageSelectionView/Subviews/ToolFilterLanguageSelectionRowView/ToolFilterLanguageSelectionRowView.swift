//
//  ToolFilterLanguageSelectionRowView.swift
//  godtools
//
//  Created by Rachael Skeath on 8/30/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ToolFilterLanguageSelectionRowView: View {
    
    private static let lightGrey = Color.getColorWithRGB(red: 151, green: 151, blue: 151, opacity: 1)
    
    private let language: ToolFilterLanguageDomainModel
    private let isSelected: Bool
    
    init(language: ToolFilterLanguageDomainModel, isSelected: Bool) {
        self.language = language
        self.isSelected = isSelected
    }
    
    var body: some View {
        
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                
                HStack(spacing: 9.5) {
                    
                    let titleFontLibrary: FontLibrary = isSelected ? FontLibrary.sfProTextBold : FontLibrary.sfProTextRegular
                    let titleFont: Font = titleFontLibrary.font(size: 15)
                    
                    if let languageName = language.languageName, !languageName.isEmpty {
                     
                        getPrimaryText(
                            text: languageName,
                            font: titleFont
                        )
                        
                        Text(language.languageNameTranslatedInAppLanguage)
                            .font(FontLibrary.sfProTextRegular.font(size: 15))
                            .foregroundColor(ToolFilterLanguageSelectionRowView.lightGrey)
                    }
                    else {
                        
                        getPrimaryText(
                            text: language.languageNameTranslatedInAppLanguage,
                            font: titleFont
                        )
                    }
                }
                
                Text(language.toolsAvailable)
                    .font(FontLibrary.sfProTextRegular.font(size: 12))
                    .foregroundColor(ToolFilterLanguageSelectionRowView.lightGrey)
            }
            .padding(.vertical, 7)
            
            Spacer()
        }
    }
    
    private func getPrimaryText(text: String, font: Font) -> Text {
        Text(text)
            .font(font)
            .foregroundColor(ColorPalette.gtGrey.color)
    }
}
