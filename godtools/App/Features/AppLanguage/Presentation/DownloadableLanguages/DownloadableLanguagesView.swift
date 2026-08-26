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
            
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(viewModel.displayedDownloadableLanguages) { downloadableLanguage in
                        DownloadableLanguageItemView(
                            viewModel: viewModel.getDownloadableLanguageItemViewModel(
                                downloadableLanguage: downloadableLanguage
                            )
                        )
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .animation(.default, value: viewModel.displayedDownloadableLanguages)
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
