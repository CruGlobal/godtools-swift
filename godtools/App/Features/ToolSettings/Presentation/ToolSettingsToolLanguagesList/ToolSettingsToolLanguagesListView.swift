//
//  ToolSettingsToolLanguagesListView.swift
//  godtools
//
//  Created by Levi Eggert on 12/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ToolSettingsToolLanguagesListView: View {
        
    @ObservedObject private var viewModel: ToolSettingsToolLanguagesListViewModel
    
    init(viewModel: ToolSettingsToolLanguagesListViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
         
            VStack(alignment: .leading, spacing: 0) {
                
                HStack {
                    Spacer()
                    CloseButton {
                        viewModel.closeTapped()
                    }
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 10))
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        ForEach(viewModel.languages) { (language: ToolSettingsToolLanguageDomainModel) in
                                                        
                            ToolSettingsToolLanguagesListItemView(
                                viewModel: viewModel.getListItemViewModel(domainModel: language),
                                tappedClosure: {
                                    
                                    viewModel.languageTapped(language: language)
                                }
                            )
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color.white)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}
