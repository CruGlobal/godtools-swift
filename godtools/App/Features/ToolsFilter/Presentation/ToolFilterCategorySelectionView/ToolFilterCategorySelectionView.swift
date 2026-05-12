//
//  ToolFilterCategorySelectionView.swift
//  godtools
//
//  Created by Rachael Skeath on 8/28/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ToolFilterCategorySelectionView: View {
    
    private static let ultraLightGrey = Color.getColorWithRGB(red: 246, green: 246, blue: 246, opacity: 1)
    
    @ObservedObject private var viewModel: ToolFilterCategorySelectionViewModel
    
    init(viewModel: ToolFilterCategorySelectionViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            AccessibilityScreenElementView(screenAccessibility: .toolsCategoryFilters)
            
            SearchBarView(viewModel: viewModel.getSearchBarViewModel(), searchText: $viewModel.searchText)
            
            List {
                ForEach(viewModel.categorySearchResults, id: \.filterId) { category in
                    
                    Button {
                        
                        viewModel.rowTapped(with: category)
                        
                    } label: {
                        
                        ToolFilterCategorySelectionRowView(
                            category: category,
                            isSelected: viewModel.selectedCategory.id == category.id
                        )
                    }
                }
            }
            .listStyle(.inset)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.strings.navTitle)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}
