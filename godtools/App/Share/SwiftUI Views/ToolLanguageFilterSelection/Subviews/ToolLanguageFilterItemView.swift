//
//  ToolLanguageFilterItemView.swift
//  godtools
//
//  Created by Levi Eggert on 9/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct ToolLanguageFilterItemView<Language: ToolLanguageFilterItemDomainModelInterface>: View {
    
    private let language: Language
    private let isSelected: Bool
    private let lightGrey = Color.getColorWithRGB(red: 151, green: 151, blue: 151, opacity: 1)
    
    init(language: Language, isSelected: Bool) {
        
        self.language = language
        self.isSelected = isSelected
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                
                HStack(spacing: 9.5) {
                    
                    let titleFontLibrary: FontLibrary = isSelected ? FontLibrary.sfProTextBold : FontLibrary.sfProTextRegular
                    let titleFont: Font = titleFontLibrary.font(size: 15)
                    
                    let nameInOwnLanguage: String = language.languageNamePair.nameInOwnLanguage
                    let nameInAppLanguage: String = language.languageNamePair.nameInAppLanguage
                    
                    if !nameInOwnLanguage.isEmpty {
                                         
                        getPrimaryText(
                            text: nameInOwnLanguage,
                            font: titleFont
                        )
                        
                        Text(nameInAppLanguage)
                            .font(FontLibrary.sfProTextRegular.font(size: 15))
                            .foregroundColor(lightGrey)
                    }
                    else {
                        
                        getPrimaryText(
                            text: nameInAppLanguage,
                            font: titleFont
                        )
                    }
                }
                
                if let availableText = language.availableText {
                    
                    Text(availableText)
                        .font(FontLibrary.sfProTextRegular.font(size: 12))
                        .foregroundColor(lightGrey)
                }
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
