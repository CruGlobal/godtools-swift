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
    @ObservedObject private var selectedCategory: CombineObservableValue<CategoryFilterDomainModel>
    
    init(viewModel: ToolFilterCategorySelectionViewModel, selectedCategory: CombineObservableValue<CategoryFilterDomainModel>) {
        
        self.viewModel = viewModel
        self.selectedCategory = selectedCategory
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            SearchBarView(viewModel: viewModel.getSearchBarViewModel(), searchText: $viewModel.searchText)
            
            List {
                ForEach(viewModel.categorySearchResults, id: \.filterId) { category in
                    
                    Button {
                        
                        selectedCategory.value = category
                        
                        viewModel.rowTapped(with: category)
                        
                    } label: {
                        
                        ToolFilterCategorySelectionRowView(
                            category: category,
                            isSelected: selectedCategory.value.id == category.id
                        )
                    }
                }
            }
            .listStyle(.inset)
        }
        .navigationBarBackButtonHidden(true) // TODO: (GT-1794) This is a temp fix for iOS 16.  Will need to update to configure the navigation bar using SwiftUI instead of UIHostingController's. ~Levi
        .navigationTitle(viewModel.navTitle)
    }
}

