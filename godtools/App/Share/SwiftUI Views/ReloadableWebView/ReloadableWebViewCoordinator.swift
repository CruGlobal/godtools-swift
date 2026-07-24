//
//  ReloadableWebViewCoordinator.swift
//  godtools
//
//  Created by Levi Eggert on 7/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import WebKit
import UIKit

@MainActor
final class ReloadableWebViewCoordinator: NSObject {
        
    private var currentWebView: WKWebView?
    private var requestUrl: URL?
    private var fallbackFileUrl: URL?
    private var didFailClosure: ((_ error: Error) -> Void)?
    
    func loadUrl(
        webView: WKWebView,
        requestUrl: URL,
        fallbackFileUrl: URL?,
        didFailClosure: ((_ error: Error) -> Void)?
    ) {
        
        guard requestUrl != self.requestUrl else {
            return
        }
        
        if let webView = currentWebView {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                webView.alpha = 0
            }
            
            stopLoading(webView: webView)
        }
        else {
            
            webView.alpha = 0
        }
        
        self.currentWebView = webView
        self.requestUrl = requestUrl
        self.fallbackFileUrl = fallbackFileUrl
        self.didFailClosure = didFailClosure
        
        webView.navigationDelegate = self
        
        webView.load(
            URLRequest(
                url: requestUrl
            )
        )
    }
    
    func stopLoading(webView: WKWebView) {
        
        currentWebView = nil
        
        webView.uiDelegate = nil
        webView.navigationDelegate = nil
        webView.stopLoading()
    }
}

// MARK: - WKNavigationDelegate

extension ReloadableWebViewCoordinator: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
                
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            webView.alpha = 1
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
                     
        let errorCode: Int = (error as NSError).code
        let notConnectedToNetwork: Bool = errorCode == Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue)
                        
        if notConnectedToNetwork, let fallbackFileUrl = fallbackFileUrl {
            
            webView.loadFileURL(
                fallbackFileUrl,
                allowingReadAccessTo: fallbackFileUrl
            )
        }
        else {
            
            didFailClosure?(error)
        }
    }
}
