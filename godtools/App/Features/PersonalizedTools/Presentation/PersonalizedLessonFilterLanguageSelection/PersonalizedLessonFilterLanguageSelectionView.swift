//
//  PersonalizedLessonFilterLanguageSelectionView.swift
//  godtools
//
//  Created by Levi Eggert on 9/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct PersonalizedLessonFilterLanguageSelectionView: View {
    
    @ObservedObject private var viewModel: PersonalizedLessonFilterLanguageSelectionViewModel
    
    init(viewModel: PersonalizedLessonFilterLanguageSelectionViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            AccessibilityScreenElementView(screenAccessibility: .personalizedLessonsLanguageFilters)
            
            ToolLanguageFilterSelectionView(
                searchText: $viewModel.searchText,
                searchBarStrings: viewModel.searchBarStrings,
                languages: viewModel.languageSearchResults,
                selectedLanguageId: viewModel.selectedLanguageId,
                languageTapped: { (languageId: String) in
                    
                    viewModel.languageTapped(languageId: languageId)
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
