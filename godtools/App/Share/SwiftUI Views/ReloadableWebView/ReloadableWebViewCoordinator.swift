//
//  ReloadableWebViewCoordinator.swift
//  godtools
//
//  Created by Levi Eggert on 7/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import WebKit

final class ReloadableWebViewCoordinator: NSObject {
    
    private let didFinishClosure: ((_ coordinator: ReloadableWebViewCoordinator, _ webView: WKWebView, _ navigation: WKNavigation) -> Void)?
    private let didFailClosure: ((_ coordinator: ReloadableWebViewCoordinator, _ webView: WKWebView, _ navigation: WKNavigation, _ error: Error) -> Void)?
    
    let requestUrl: URL
    let fallbackFileUrl: URL?
    
    init(
        requestUrl: URL,
        fallbackFileUrl: URL?,
        didFinishClosure: ((_ coordinator: ReloadableWebViewCoordinator, _ webView: WKWebView, _ navigation: WKNavigation) -> Void)?,
        didFailClosure: ((_ coordinator: ReloadableWebViewCoordinator, _ webView: WKWebView, _ navigation: WKNavigation, _ error: Error) -> Void)?
    ) {
              
        self.requestUrl = requestUrl
        self.fallbackFileUrl = fallbackFileUrl
        self.didFinishClosure = didFinishClosure
        self.didFailClosure = didFailClosure
    }
}

// MARK: - WKNavigationDelegate

extension ReloadableWebViewCoordinator: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
                
        didFinishClosure?(self, webView, navigation)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
                     
        didFailClosure?(self, webView, navigation, error)
    }
}
