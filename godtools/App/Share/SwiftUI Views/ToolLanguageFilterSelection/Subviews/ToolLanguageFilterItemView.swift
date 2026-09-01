//
//  ToolLanguageFilterItemView.swift
//  godtools
//
//  Created by Levi Eggert on 9/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct ToolLanguageFilterItemView: View {
    
    private static let lightGrey = Color.getColorWithRGB(red: 151, green: 151, blue: 151, opacity: 1)
    
    private let language: ToolLanguageFilterDomainModel
    private let isSelected: Bool
    
    init(language: ToolLanguageFilterDomainModel, isSelected: Bool) {
        
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
                        .foregroundColor(Self.lightGrey)
                }
                
                if let availableText = language.availableText {
                    
                    Text(availableText)
                        .font(FontLibrary.sfProTextRegular.font(size: 12))
                        .foregroundColor(Self.lightGrey)
                }
            }
            .padding(.vertical, 7)
            
            Spacer()
        }
    }
}
