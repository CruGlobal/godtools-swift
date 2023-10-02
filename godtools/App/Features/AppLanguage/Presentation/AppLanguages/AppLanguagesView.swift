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
            
            LazyVStack(alignment: .leading, spacing: 0) {
                
                ForEach(viewModel.appLanguages) { (appLanguage: AppLanguageListItemDomainModel) in
                                                
                    AppLanguageItemView(appLanguage: appLanguage) {
                        viewModel.appLanguageTapped(appLanguage: appLanguage)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}
