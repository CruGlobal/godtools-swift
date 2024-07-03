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
            
            SearchBarView(viewModel: viewModel.getSearchBarViewModel(), searchText: $viewModel.searchText)
            
            List {
                ForEach(viewModel.languageSearchResults) { language in
                    
                    Button {
                        
                        viewModel.rowTapped(with: language)
                        
                    } label: {
                        
                        LessonFilterLanguageSelectionRowView(
                            language: language,
                            isSelected: viewModel.selectedLanguage.id == language.id
                        )
                    }
                }
            }
            .listStyle(.inset)
        }
        .navigationBarBackButtonHidden(true) // TODO: (GT-1794) This is a temp fix for iOS 16.  Will need to update to configure the navigation bar using SwiftUI instead of UIHostingController's. ~Levi
        .navigationTitle(viewModel.navTitle)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}
