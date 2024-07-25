//
//  LessonFilterLanguageSelectionRowView.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import SwiftUI

struct LessonFilterLanguageSelectionRowView: View {
    
    private static let lightGrey = Color.getColorWithRGB(red: 151, green: 151, blue: 151, opacity: 1)
    
    private let language: LessonLanguageFilterDomainModel
    private let isSelected: Bool
    
    init(language: LessonLanguageFilterDomainModel, isSelected: Bool) {
        self.language = language
        self.isSelected = isSelected
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                
                HStack(spacing: 9.5) {
                    
                    let titleFont = isSelected ? FontLibrary.sfProTextBold : FontLibrary.sfProTextRegular
                    
                    Text(language.languageName)
                        .font(titleFont.font(size: 15))
                        .foregroundColor(ColorPalette.gtGrey.color)
                                            
                    Text(language.translatedName)
                        .font(FontLibrary.sfProTextRegular.font(size: 15))
                        .foregroundColor(LessonFilterLanguageSelectionRowView.lightGrey)
                }
                
                Text(language.lessonsAvailableText)
                    .font(FontLibrary.sfProTextRegular.font(size: 12))
                    .foregroundColor(LessonFilterLanguageSelectionRowView.lightGrey)
            }
            .padding(.vertical, 7)
            
            Spacer()
        }
    }
}
