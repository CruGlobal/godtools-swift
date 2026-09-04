//
//  LessonFilterLanguageSelectionView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import SwiftUI

struct LessonFilterLanguageSelectionView: View {
    
    @ObservedObject private var viewModel: LessonFilterLanguageSelectionViewModel
    
    init(viewModel: LessonFilterLanguageSelectionViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            AccessibilityScreenElementView(screenAccessibility: .lessonsLanguageFilters)
            
            ToolLanguageFilterSelectionView(
                searchText: $viewModel.searchText,
                searchBarStrings: viewModel.searchBarStrings,
                languages: viewModel.languageSearchResults,
                selectedLanguage: viewModel.selectedLanguage,
                languageTapped: { (language: LessonFilterLanguageDomainModel) in
                    
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
