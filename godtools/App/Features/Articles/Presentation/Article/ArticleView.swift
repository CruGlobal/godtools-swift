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
            
            if let loadArticleError = viewModel.loadArticleError {
                
                ArticlesErrorMessageView(
                    geometry: geometry,
                    horizontalPadding: 30,
                    error: loadArticleError,
                    actionTapped: {
                        viewModel.downloadArticleTapped()
                    }
                )
                .padding([.top], 64)
            }
            else if let requestUrl = viewModel.loadArticleRequestUrl {
                
                CenteredCircularProgressView(progressColor: .black)
                
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
        .navBar(
            title: viewModel.navTitle,
            backItem: BackToolbarItem(
                tapped: {
                    viewModel.backTapped()
                }
            ),
            toolbarContent: {
                
                if !viewModel.hidesShareButton {
                    
                    AppToolbarItem(
                        placement: AppToolbarItem.trailingPlacement,
                        viewType: .image(value: ImageCatalog.navShare.image),
                        color: ColorPalette.gtBlue.color,
                        accessibilityId: nil,
                        tappedClosure: {
                            
                            viewModel.sharedTapped()
                        }
                    )
                }
                
                if !viewModel.hidesDebugButton {
                    
                    AppToolbarItem(
                        placement: AppToolbarItem.trailingPlacement,
                        viewType: .image(value: ImageCatalog.navDebug.image),
                        color: ColorPalette.gtBlue.color,
                        accessibilityId: AccessibilityStrings.Button.share.id,
                        tappedClosure: {
                            
                            viewModel.debugTapped()
                        }
                    )
                }
            }
        )
        .background(Color.white)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
        .onAppear {
            viewModel.pageViewed()
        }
    }
}
