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
        
    private let requestUrl: URL
    private let fallbackFileUrl: URL?
    
    init(requestUrl: URL, fallbackFileUrl: URL?) {
                
        self.requestUrl = requestUrl
        self.fallbackFileUrl = fallbackFileUrl
    }
    
    func makeCoordinator() -> ReloadableWebViewCoordinator {
        
        return ReloadableWebViewCoordinator(
            requestUrl: requestUrl,
            fallbackFileUrl: fallbackFileUrl,
            didFinishClosure: { (coordinator: ReloadableWebViewCoordinator, webView: WKWebView, navigation: WKNavigation) in
                                
            }, didFailClosure: { (coordinator: ReloadableWebViewCoordinator, webView: WKWebView, navigation: WKNavigation, error: Error) in
                
                let errorCode: Int = (error as NSError).code
                let notConnectedToNetwork: Bool = errorCode == Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue)
                                
                if notConnectedToNetwork, let fallbackFileUrl = coordinator.fallbackFileUrl {
                    
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
                
        let webView = WKWebView(frame: UIScreen.main.bounds)
        
        webView.scrollView.showsVerticalScrollIndicator = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        webView.navigationDelegate = context.coordinator
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
         
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
