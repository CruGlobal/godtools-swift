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
        }
        
//        GeometryReader { geometry in
//
//            LazyVStack(alignment: .leading, spacing: 0) {
//
//                ForEach(viewModel.appLanguages) { (appLanguage: AppLanguageDomainModel) in
//                                                
//                    AppLanguageItemView(appLanguage: appLanguage) {
//                        viewModel.appLanguageTapped(appLanguage: appLanguage)
//                    }
//                }
//            }
//        }
        .navigationBarBackButtonHidden(true)
    }
}
