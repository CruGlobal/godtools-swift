//
//  ReloadableWebViewRepresentable.swift
//  godtools
//
//  Created by Levi Eggert on 7/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import WebKit

struct ReloadableWebViewRepresentable: UIViewRepresentable {
        
    private var requestUrl: URL
    private var fallbackFileUrl: URL?
    
    init(requestUrl: URL, fallbackFileUrl: URL?) {
        
        print("\n ReloadableWebViewRepresentable init() !!!")
        
        self.requestUrl = requestUrl
        self.fallbackFileUrl = fallbackFileUrl
    }
    
    func makeCoordinator() -> ReloadableWebViewCoordinator {
        
        return ReloadableWebViewCoordinator(
            didFinishClosure: { (webView: WKWebView, navigation: WKNavigation) in
                
                print("\n DID FINISH WEBVIEW")
                
            }, didFailClosure: { (webView: WKWebView, navigation: WKNavigation, error: Error) in
                
                let errorCode: Int = (error as NSError).code
                let notConnectedToNetwork: Bool = errorCode == Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue)
                
                print("\n DID FAIL WEBVIEW")
                print("  error.code: \(errorCode)")
                print("  error.localizedDescription: \(error.localizedDescription)")
                
                if notConnectedToNetwork, let fallbackFileUrl = self.fallbackFileUrl {
                    
                    webView.loadFileURL(
                        fallbackFileUrl,
                        allowingReadAccessTo: fallbackFileUrl
                    )
                }
                else {
                    
                    //let errorTitle: String = "Load Article Error"
                    //let errorMessage: String = error.localizedDescription
                }
            })
    }
    
    func makeUIView(context: Context) -> WKWebView {
        
        print("\n MAKE VIEW")
        
        let webView = WKWebView(frame: UIScreen.main.bounds)
        
        webView.alpha = 0
        webView.scrollView.showsVerticalScrollIndicator = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        webView.navigationDelegate = context.coordinator
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
        print("\n UPDATE VIEW")
        
        guard !uiView.isLoading else {
            return
        }
        
        print("\n --> LOAD URL")
        
        uiView.load(
            URLRequest(
                url: requestUrl
            )
        )
    }
    
    func stopLoading() {
        
//        webView.uiDelegate = nil
//        webView.navigationDelegate = nil
//        webView.stopLoading()
    }
}
