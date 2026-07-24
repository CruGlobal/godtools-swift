//
//  ReloadableWebView.swift
//  godtools
//
//  Created by Levi Eggert on 7/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import WebKit

struct ReloadableWebView: UIViewRepresentable {
        
    private let requestUrl: URL
    private let fallbackFileUrl: URL?
    private let completion: ((_ url: URL?, _ error: Error?) -> Void)?
    
    init(requestUrl: URL, fallbackFileUrl: URL?, completion: ((_ url: URL?, _ error: Error?) -> Void)?) {
                
        self.requestUrl = requestUrl
        self.fallbackFileUrl = fallbackFileUrl
        self.completion = completion
    }
    
    func makeCoordinator() -> ReloadableWebViewCoordinator {
        
        return ReloadableWebViewCoordinator()
    }
    
    func makeUIView(context: Context) -> WKWebView {
                
        let webView = WKWebView(frame: UIScreen.main.bounds)
        
        webView.alpha = 0
        webView.scrollView.showsVerticalScrollIndicator = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
         
        context.coordinator.loadUrl(
            webView: uiView,
            requestUrl: requestUrl,
            fallbackFileUrl: fallbackFileUrl,
            completion: completion
        )
    }
    
    static func dismantleUIView(_ uiView: WKWebView, coordinator: ReloadableWebViewCoordinator) {

        coordinator.stopLoading()
    }
}
