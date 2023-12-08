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
                
                DownloadableLanguageItemView(languageDownloadStatus: .downloaded, tappedClosure: nil)
                    .listRowBackground(Color.clear)
                DownloadableLanguageItemView(languageDownloadStatus: .notDownloaded, tappedClosure: nil)
                    .listRowBackground(Color.clear)
                DownloadableLanguageItemView(languageDownloadStatus: .notDownloaded, tappedClosure: nil)
                    .listRowBackground(Color.clear)
            }
            .listStyle(.inset)
            .foregroundColor(.clear)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.navTitle)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}
