//
//  ArticlesView.swift
//  godtools
//
//  Created by Levi Eggert on 6/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct ArticlesView: View {
    
    @ObservedObject private var viewModel: ArticlesViewModel
    
    init(viewModel: ArticlesViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            FullScreenDownloadProgressView()
                .opacity(viewModel.isLoading ? 1 : 0)
                .animation(.easeOut(duration: 0.2), value: viewModel.isLoading)
            
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.articles) { article in
                        
                        ArticleItemView(
                            article: article,
                            tappedClosure: {
                                
                                viewModel.articleTapped(article: article)
                            }
                        )
                    }
                }
            }
            
            if let articlesError = viewModel.articlesError {
                ArticlesErrorMessageView(
                    title: articlesError.title,
                    message: articlesError.message,
                    actionTitle: articlesError.downloadActionTitle,
                    actionTapped: {
                        
                        viewModel.downloadArticlesTapped()
                    }
                )
                .padding([.top], 64)
                .padding([.horizontal], 30)
            }
        }
        .navigationTitle(viewModel.navTitle)
        .navigationBarBackButtonHidden(true)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}
