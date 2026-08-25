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
            
            let articlesError: ArticlesErrorDomainModel? = viewModel.articlesError ?? viewModel.downloadArticlesError
            
            if let articlesError = articlesError {
                
                ArticlesErrorMessageView(
                    geometry: geometry,
                    horizontalPadding: 30,
                    error: articlesError,
                    actionTapped: {
                        viewModel.downloadArticlesTapped()
                    }
                )
                .padding([.top], 64)
            }
            else {
                
                PullToRefreshScrollView(showsIndicators: false) {
                    
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
                } refreshHandler: {
                    
                    viewModel.pullToRefresh()
                }
            }
        }
        .navBar(
            title: viewModel.navTitle,
            backTapped: {
                viewModel.backTapped()
            }
        )
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}
