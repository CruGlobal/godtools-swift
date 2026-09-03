//
//  PersonalizedToolFilterLanguageSelectionView.swift
//  godtools
//
//  Created by Levi Eggert on 9/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct PersonalizedToolFilterLanguageSelectionView: View {
    
    @ObservedObject private var viewModel: PersonalizedToolFilterLanguageSelectionViewModel
    
    init(viewModel: PersonalizedToolFilterLanguageSelectionViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            AccessibilityScreenElementView(screenAccessibility: .personalizedToolsLanguageFilters)
            
            ToolLanguageFilterSelectionView(
                searchText: $viewModel.searchText,
                searchBarStrings: viewModel.searchBarStrings,
                languages: viewModel.languageSearchResults,
                selectedLanguage: viewModel.selectedLanguage,
                languageTapped: { (language: PersonalizedToolFilterLanguageDomainModel) in
                    
                    viewModel.languageTapped(language: language)
                }
            )
        }
        .navBar(
            title: viewModel.strings.navTitle,
            backItem: BackToolbarItem(
                tapped: {
                    viewModel.backTapped()
                }
            )
        )
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}
