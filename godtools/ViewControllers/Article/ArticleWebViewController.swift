//
//  ArticleWebViewController.swift
//  godtools
//
//  Created by Igor Ostriz on 18/12/2018.
//  Copyright © 2018 Cru. All rights reserved.
//


import UIKit
import WebKit


class ArticleWebViewController: BaseViewController{

    static func create() -> ArticleWebViewController {
        let storyboard = UIStoryboard(name: Storyboard.articles, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "ArticleWebViewControllerID") as! ArticleWebViewController
    }

    
    var data: ArticleData?
    var webView: WKWebView!
    
    
    override var screenTitle: String {
        return data?.title ?? super.screenTitle
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        var scriptContent = "var meta = document.createElement('meta');"
        scriptContent += "meta.name='viewport';"
        scriptContent += "meta.content='width=device-width';"
        scriptContent += "document.getElementsByTagName('head')[0].appendChild(meta);"

        let userScript = WKUserScript(source: scriptContent, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)
        let webConfig = WKWebViewConfiguration()
        webConfig.userContentController = contentController

        // cannot use storyboard for WKWebView prior to iOS 11
        webView = WKWebView(frame: view.bounds, configuration: webConfig)
//        webView = WKWebView(frame: view.bounds)
        view.addSubview(webView)
        
        webView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
  
        webView.navigationDelegate = self
        
        if let url = data?.local {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }

//
//        var scriptContent = "var meta = document.createElement('meta');"
//        scriptContent += "meta.name='viewport';"
//        scriptContent += "meta.content='width=device-width';"
//        scriptContent += "document.getElementsByTagName('head')[0].appendChild(meta);"
//
//        webView.evaluateJavaScript(scriptContent, completionHandler: nil)
        // load web page
        // file:///var/mobile/Containers/Data/Application/533F8448-22C3-484D-9935-F96AB1BF770A/Documents/WebCache/63fda9c5e185bbf3698e2a9f5de93a6bbd7aa776bf82f93e76f24987abde92af/faith-topics:jesus-christ%23death-of-jesus/01/page.webarchive
//        let url = URL(string: data?.uri ?? "")
    }
    
}


extension ArticleWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("web content did finish")

    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("web did commit")

//        var scriptContent = "var meta = document.createElement('meta');"
//        scriptContent += "meta.name='viewport';"
//        scriptContent += "meta.content='width=device-width';"
//        scriptContent += "document.getElementsByTagName('head')[0].appendChild(meta);"
//        webView.evaluateJavaScript(scriptContent, completionHandler: nil)
    }
}
