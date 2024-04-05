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
    
    private let language: LanguageFilterDomainModel
    private let isSelected: Bool
    
    init(language: LanguageFilterDomainModel, isSelected: Bool) {
        self.language = language
        self.isSelected = isSelected
    }
    
    var body: some View {
        
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                
                HStack(spacing: 9.5) {
                    
                    let titleFont = isSelected ? FontLibrary.sfProTextBold : FontLibrary.sfProTextRegular
                    
                    Text(language.primaryText)
                        .font(titleFont.font(size: 15))
                        .foregroundColor(ColorPalette.gtGrey.color)
                    
                    if let translatedName = language.translatedName {
                        
                        Text(translatedName)
                            .font(FontLibrary.sfProTextRegular.font(size: 15))
                            .foregroundColor(ToolFilterLanguageSelectionRowView.lightGrey)
                    }
                }
                
                Text(language.toolsAvailableText)
                    .font(FontLibrary.sfProTextRegular.font(size: 12))
                    .foregroundColor(ToolFilterLanguageSelectionRowView.lightGrey)
            }
            .padding(.vertical, 7)
            
            Spacer()
        }
    }
}
