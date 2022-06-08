//
//  LanguagesListView.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LanguagesListView: View {
        
    @ObservedObject var viewModel: LanguagesListViewModel
    
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
                    
                    if !viewModel.hidesDeleteOption {
                        
                        let deleteItemViewModel = DeleteLanguageListItemViewModel()
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

struct LanguagesListView_Preview: PreviewProvider {
    static var previews: some View {
        
        let languages: [ToolLanguageModel] = [
            ToolLanguageModel(id: "en", name: "English"),
            ToolLanguageModel(id: "es", name: "Spanish")
        ]
        
        let selectedLanguageId = "en"
        
        let viewModel = LanguagesListViewModel(languages: languages, selectedLanguageId: selectedLanguageId, closeTappedClosure: {
            
        }, languageTappedClosure: { language in
            
        }, deleteTappedClosure: nil)
        
        return LanguagesListView(viewModel: viewModel)
    }
}
