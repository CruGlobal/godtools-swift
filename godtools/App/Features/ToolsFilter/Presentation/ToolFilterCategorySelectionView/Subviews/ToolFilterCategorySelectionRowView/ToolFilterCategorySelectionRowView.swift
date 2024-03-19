//
//  ToolFilterCategorySelectionRowView.swift
//  godtools
//
//  Created by Rachael Skeath on 8/30/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ToolFilterCategorySelectionRowView: View {
    
    private static let lightGrey = Color.getColorWithRGB(red: 151, green: 151, blue: 151, opacity: 1)
    
    private let category: CategoryFilterDomainModel
    private let tappedClosure: (() -> Void)?
    
    @Binding private var selectedCategory: CategoryFilterDomainModel
    
    init(category: CategoryFilterDomainModel, selectedCategory: Binding<CategoryFilterDomainModel>, tappedClosure: (() -> Void)?) {
        self.category = category
        self._selectedCategory = selectedCategory
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                
                HStack(spacing: 9.5) {
                    
                    let titleFont = isSelected ? FontLibrary.sfProTextBold : FontLibrary.sfProTextRegular
                    
                    Text(category.primaryText)
                        .font(titleFont.font(size: 15))
                        .foregroundColor(ColorPalette.gtGrey.color)
                }
                
                Text(category.toolsAvailableText)
                    .font(FontLibrary.sfProTextRegular.font(size: 12))
                    .foregroundColor(ToolFilterCategorySelectionRowView.lightGrey)
            }
            .padding(.vertical, 7)
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            
            selectedCategory = category
            
            tappedClosure?()
        }
    }
    
    private var isSelected: Bool {
        return selectedCategory.id == category.id
    }
}

