//
//  LanguagesListView.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LanguagesListView: View {
        
    @ObservedObject private var viewModel: LanguagesListViewModel
    
    init(viewModel: LanguagesListViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
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
                    
                    if let deleteItemViewModel = viewModel.getDeleteLanguageListItemViewModel() {
                        
                        let itemView = LanguagesListItemView(viewModel: deleteItemViewModel)
                        
                        itemView
                            .onTapGesture {
                                viewModel.deleteTapped()
                            }
                    }
                    
                    ForEach(viewModel.languages) { language in
                        
                        let itemViewModel = viewModel.getLanguagesListItemViewModel(language: language)
                        let itemView = LanguagesListItemView(viewModel: itemViewModel)

                        itemView
                            .onTapGesture {
                                viewModel.languageTapped(language: language)
                            }
                    }
                }
            }
        }
        .background(Color.white)
    }
}
