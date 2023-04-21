//
//  ArticleDebugViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

class ArticleDebugViewModel: ObservableObject {
    
    private let article: ArticleDomainModel
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var url: String
    @Published var urlType: String
    
    init(flowDelegate: FlowDelegate, article: ArticleDomainModel) {
        
        self.flowDelegate = flowDelegate
        self.article = article
        
        url = article.url?.absoluteString ?? ""
        
        if let articleUrlType = article.urlType {
            
            switch articleUrlType {
            case .fileUrl:
                urlType = "web archive file url"
            case .url:
                urlType = "http url"
            }
        }
        else {
            urlType = ""
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
