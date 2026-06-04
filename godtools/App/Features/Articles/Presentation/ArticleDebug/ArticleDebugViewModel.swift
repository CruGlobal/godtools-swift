//
//  ArticleDebugViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

@MainActor
final class ArticleDebugViewModel: ObservableObject {
        
    private weak var flowDelegate: FlowDelegate?
    
    @Published private(set) var url: String
    @Published private(set) var urlType: String
    
    init(flowDelegate: FlowDelegate, articleUrl: ArticleUrlDomainModel) {
        
        self.flowDelegate = flowDelegate
        
        url = articleUrl.url.absoluteString
        
        switch articleUrl.urlType {
        case .archive:
            urlType = "web archive file url"
        case .https:
            urlType = "http url"
        }
    }
}

// MARK: - Inputs

extension ArticleDebugViewModel {
    
    @objc func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromArticleDebug)
    }
    
    func copyUrlTapped() {
        
        UIPasteboard.general.setValue(url, forPasteboardType: "public.plain-text")
    }
}
