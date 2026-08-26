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
            
            SearchBarView(searchText: $viewModel.searchText, strings: viewModel.searchBarStrings)
            
            List {
                ForEach(viewModel.languageSearchResults) { language in
                    
                    Button {
                        
                        viewModel.languageTapped(language: language)
                        
                    } label: {
                        
                        LessonFilterLanguageSelectionRowView(
                            language: language,
                            isSelected: viewModel.selectedLanguage?.id == language.id
                        )
                    }
                }
            }
            .listStyle(.inset)
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
