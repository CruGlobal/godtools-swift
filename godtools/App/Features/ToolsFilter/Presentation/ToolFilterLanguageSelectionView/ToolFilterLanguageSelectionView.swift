//
//  ToolFilterLanguageSelectionView.swift
//  godtools
//
//  Created by Rachael Skeath on 8/28/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ToolFilterLanguageSelectionView: View {
        
    @ObservedObject private var viewModel: ToolFilterLanguageSelectionViewModel
    
    init(viewModel: ToolFilterLanguageSelectionViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            AccessibilityScreenElementView(screenAccessibility: .toolsLanguageFilters)
            
            ToolLanguageFilterSelectionView(
                searchText: $viewModel.searchText,
                searchBarStrings: viewModel.searchBarStrings,
                languages: viewModel.languageSearchResults,
                selectedId: viewModel.selectedLanguageId,
                languageTapped: { (id: String) in
                    
                    viewModel.languageTapped(id: id)
                }
            )
        }
        .navBar(
            title: viewModel.strings.navTitle,
            backItem: BackToolbarItem(
                tapped: {
                    viewModel.backButtonTapped()
                }
            )
        )
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}
