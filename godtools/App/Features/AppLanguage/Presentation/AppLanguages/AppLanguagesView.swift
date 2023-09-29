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
        
        VStack(spacing: 0) {
            
            SearchBarView(viewModel: viewModel.getSearchBarViewModel())
            
            List {
                ForEach(viewModel.appLanguages) { appLanguage in
                    
                    AppLanguageItemView(appLanguage: appLanguage) {
                        
                        viewModel.appLanguageTapped(appLanguage: appLanguage)
                    }
                }
            }
            .listStyle(.inset)
        }
        .navigationBarBackButtonHidden(true)
    }
}
