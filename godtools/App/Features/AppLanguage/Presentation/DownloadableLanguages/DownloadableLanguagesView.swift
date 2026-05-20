//
//  DownloadableLanguagesView.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct DownloadableLanguagesView: View {
    
    @ObservedObject private var viewModel: DownloadableLanguagesViewModel
    
    init(viewModel: DownloadableLanguagesViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            AccessibilityScreenElementView(screenAccessibility: .downloadableLanguages)
                                    
            SearchBarView(searchText: $viewModel.searchText, strings: viewModel.searchBarStrings)
            
            List {
                ForEach(viewModel.displayedDownloadableLanguages) { downloadableLanguage in
                    
                    DownloadableLanguageItemView(
                        viewModel: viewModel.getDownloadableLanguageItemViewModel(
                            downloadableLanguage: downloadableLanguage
                        )
                    )
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.inset)
            .animation(.default, value: viewModel.displayedDownloadableLanguages)
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.strings.navTitle)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}
