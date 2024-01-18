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
                                    
            SearchBarView(viewModel: viewModel.getSearchBarViewModel(), searchText: $viewModel.searchText)
            
            List {
                ForEach(viewModel.displayedDownloadableLanguages) { downloadableLanguage in
                    
                    DownloadableLanguageItemView(downloadableLanguage: downloadableLanguage) {
                        
                        viewModel.downloadableLanguageTapped(downloadableLanguage: downloadableLanguage)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.inset)
            .animation(.default, value: viewModel.displayedDownloadableLanguages)
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.navTitle)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}
