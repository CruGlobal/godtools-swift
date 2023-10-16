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
    @State var showingPopup = false
    
    init(viewModel: AppLanguagesViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            SearchBarView(viewModel: viewModel.getSearchBarViewModel())
            
            List {
                ForEach(viewModel.appLanguageSearchResults) { appLanguage in
                    
                    AppLanguageItemView(appLanguage: appLanguage) {
                        
                        showingPopup = true

//                        viewModel.appLanguageTapped(appLanguage: appLanguage)
                    }
                }
            }
            .listStyle(.inset)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.navTitle)
        .popover(isPresented: $showingPopup, content: {
            ConfirmAppLanguageView()
        })
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}
