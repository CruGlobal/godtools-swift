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
    
    private let didFinishClosure: ((_ webView: WKWebView, _ navigation: WKNavigation) -> Void)?
    private let didFailClosure: ((_ webView: WKWebView, _ navigation: WKNavigation, _ error: Error) -> Void)?
    
    init(
        didFinishClosure: ((_ webView: WKWebView, _ navigation: WKNavigation) -> Void)?,
        didFailClosure: ((_ webView: WKWebView, _ navigation: WKNavigation, _ error: Error) -> Void)?
    ) {
              
        self.didFinishClosure = didFinishClosure
        self.didFailClosure = didFailClosure
    }
}

// MARK: - WKNavigationDelegate

extension ReloadableWebViewCoordinator: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
                
        didFinishClosure?(webView, navigation)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
                     
        didFailClosure?(webView, navigation, error)
    }
}
