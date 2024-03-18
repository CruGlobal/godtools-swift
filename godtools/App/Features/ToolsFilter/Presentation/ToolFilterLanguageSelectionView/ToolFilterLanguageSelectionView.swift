//
//  ToolFilterLanguageSelectionView.swift
//  godtools
//
//  Created by Rachael Skeath on 8/28/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ToolFilterLanguageSelectionView: View {
    
    private static let ultraLightGrey = Color.getColorWithRGB(red: 246, green: 246, blue: 246, opacity: 1)
    
    @ObservedObject private var viewModel: ToolFilterLanguageSelectionViewModel
    @ObservedObject private var selectedLanguage: CombineObservableValue<LanguageFilterDomainModel>
        
    init(viewModel: ToolFilterLanguageSelectionViewModel, selectedLanguage: CombineObservableValue<LanguageFilterDomainModel>) {
        
        self.viewModel = viewModel
        self.selectedLanguage = selectedLanguage
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            SearchBarView(viewModel: viewModel.getSearchBarViewModel(), searchText: $viewModel.searchText)
            
            List {
                ForEach(viewModel.languageSearchResults, id: \.filterId) { language in
                    
                    Button {
                        
                        selectedLanguage.value = language
                        
                        viewModel.rowTapped(with: language)
                        
                    } label: {
                        
                        ToolFilterLanguageSelectionRowView(
                            language: language,
                            isSelected: selectedLanguage.value.id == language.id
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
