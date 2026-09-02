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
                    
                    let titleFont = isSelected ? FontLibrary.sfProTextBold : FontLibrary.sfProTextRegular
                    
                    Text(language.languageNameTranslatedInLanguage)
                        .font(titleFont.font(size: 15))
                        .foregroundColor(ColorPalette.gtGrey.color)
                                            
                    Text(language.languageNameTranslatedInAppLanguage)
                        .font(FontLibrary.sfProTextRegular.font(size: 15))
                        .foregroundColor(lightGrey)
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
}
