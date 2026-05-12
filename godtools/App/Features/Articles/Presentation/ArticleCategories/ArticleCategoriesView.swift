//
//  ArticleCategoriesView.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct ArticleCategoriesView: View {
    
    @ObservedObject private var viewModel: ArticleCategoriesViewModel
    
    init(viewModel: ArticleCategoriesViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            PullToRefreshScrollView(showsIndicators: false) {
                
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.categories) { category in
                        
                        ArticleCategoryItemView(
                            category: category,
                            width: geometry.size.width,
                            tappedClosure: {
                                viewModel.categoryTapped(category: category)
                            }
                        )
                    }
                }
                
            } refreshHandler: {
                
                viewModel.pullToRefresh()
            }
        }
        .onAppear {
            
        }
        .navigationBarBackButtonHidden(true)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}
