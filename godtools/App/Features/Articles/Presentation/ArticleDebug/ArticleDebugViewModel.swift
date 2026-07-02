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
        
    private let stepEmitter: FlowStepEmitter
        
    @Published private(set) var url: String
    @Published private(set) var urlType: String
    
    init(stepEmitter: FlowStepEmitter, articleUrl: ArticleUrlDomainModel) {
        
        self.stepEmitter = stepEmitter
        
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
        stepEmitter.emit(step: AppFlowStep.closeTappedFromArticleDebug)
    }
    
    func copyUrlTapped() {
        
        UIPasteboard.general.setValue(url, forPasteboardType: "public.plain-text")
    }
}
