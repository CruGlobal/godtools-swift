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
    private var didAttemptFallbackFileUrl: Bool = false
    private var completion: ((_ error: Error?) -> Void)?
    
    func loadUrl(
        webView: WKWebView,
        requestUrl: URL,
        fallbackFileUrl: URL?,
        completion: ((_ error: Error?) -> Void)?
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
        
        didAttemptFallbackFileUrl = false
        
        webView.navigationDelegate = self
        
        webView.load(
            URLRequest(
                url: requestUrl
            )
        )
    }
    
    func stopLoading() {
        
        self.requestUrl = nil
        self.fallbackFileUrl = nil
        self.completion = nil
        
        currentWebView?.uiDelegate = nil
        currentWebView?.navigationDelegate = nil
        currentWebView?.stopLoading()
        
        self.currentWebView = nil
    }
    
    private func didFinishLoading(error: Error?) {
        
        completion?(error)
    }
}

// MARK: - WKNavigationDelegate

extension ReloadableWebViewCoordinator: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
                
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            webView.alpha = 1
        }

        didFinishLoading(error: nil)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
                     
        let errorCode: Int = (error as NSError).code
        let notConnectedToNetwork: Bool = errorCode == Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue)
                        
        if notConnectedToNetwork, let fallbackFileUrl = fallbackFileUrl, !didAttemptFallbackFileUrl {
            
            didAttemptFallbackFileUrl = true
            
            webView.loadFileURL(fallbackFileUrl, allowingReadAccessTo: fallbackFileUrl)
        }
        else {
            
            didFinishLoading(error: error)
        }
    }
}
