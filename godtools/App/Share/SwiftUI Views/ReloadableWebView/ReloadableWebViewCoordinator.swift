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
    private var loadingUrl: URL?
    private var didAttemptFallbackFileUrl: Bool = false
    private var completion: ((_ url: URL?, _ error: Error?) -> Void)?
    
    func loadUrl(
        webView: WKWebView,
        requestUrl: URL,
        fallbackFileUrl: URL?,
        completion: ((_ url: URL?, _ error: Error?) -> Void)?
    ) {
                
        let didChangeRequestUrl: Bool = self.requestUrl != requestUrl
        
        if didChangeRequestUrl {
            stopLoading()
        }
        
        guard self.requestUrl == nil else {
            return
        }
                
        self.currentWebView = webView
        self.requestUrl = requestUrl
        self.fallbackFileUrl = fallbackFileUrl
        self.completion = completion
        
        loadingUrl = requestUrl
        
        didAttemptFallbackFileUrl = false
        
        webView.navigationDelegate = self
        
        webView.load(
            URLRequest(
                url: requestUrl
            )
        )
    }
    
    func stopLoading() {
        
        requestUrl = nil
        fallbackFileUrl = nil
        loadingUrl = nil
        completion = nil
        
        currentWebView?.uiDelegate = nil
        currentWebView?.navigationDelegate = nil
        currentWebView?.stopLoading()
        currentWebView = nil
    }
    
    private func didFinishLoading(url: URL?, error: Error?) {
        
        completion?(url, error)
    }
}

// MARK: - WKNavigationDelegate

extension ReloadableWebViewCoordinator: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
                
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            webView.alpha = 1
        }

        didFinishLoading(url: loadingUrl, error: nil)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
                     
        let errorCode: Int = (error as NSError).code
        let notConnectedToNetwork: Bool = errorCode == Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue)
                        
        if notConnectedToNetwork, let fallbackFileUrl = fallbackFileUrl, !didAttemptFallbackFileUrl {
            
            loadingUrl = fallbackFileUrl
            
            didAttemptFallbackFileUrl = true
            
            webView.loadFileURL(fallbackFileUrl, allowingReadAccessTo: fallbackFileUrl)
        }
        else {
            
            didFinishLoading(url: loadingUrl, error: error)
        }
    }
}
