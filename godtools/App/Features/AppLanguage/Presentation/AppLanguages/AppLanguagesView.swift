//
//  AppLanguagesView.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct AppLanguagesView: View {
    
    @ObservedObject private var viewModel: AppLanguagesViewModel
    
    init(viewModel: AppLanguagesViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(spacing: 0) {
                
                AccessibilityScreenElementView(screenAccessibility: .appLanguages)
                            
                SearchBarView(searchText: $viewModel.searchText, strings: viewModel.searchBarStrings)
                
                List {
                    ForEach(viewModel.appLanguageSearchResults) { appLanguage in
                        
                        AppLanguageItemView(appLanguage: appLanguage) {
                            
                            viewModel.appLanguageTapped(appLanguage: appLanguage)
                        }
                    }
                }
                .listStyle(.inset)
            }
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
