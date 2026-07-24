//
//  ArticleView.swift
//  godtools
//
//  Created by Levi Eggert on 7/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct ArticleView: View {
    
    @ObservedObject private var viewModel: ArticleViewModel
    
    init(viewModel: ArticleViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            CenteredCircularProgressView(progressColor: .black)
            
            if let requestUrl = viewModel.requestUrl {
                
                ReloadableWebView(
                    requestUrl: requestUrl,
                    fallbackFileUrl: viewModel.fallbackFileUrl,
                    completion: { (url: URL?, error: Error?) in
                        
                        viewModel.didLoadArticle(url: url, error: error)
                    }
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.navTitle)
        .background(Color.white)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
        .onAppear {
            viewModel.pageViewed()
        }
    }
}
