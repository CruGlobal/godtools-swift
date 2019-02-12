//
//  ArticleWebViewController.swift
//  godtools
//
//  Created by Igor Ostriz on 18/12/2018.
//  Copyright © 2018 Cru. All rights reserved.
//


import UIKit
import WebKit


class ArticleWebViewController: BaseViewController {

    static func create() -> ArticleWebViewController {
        let storyboard = UIStoryboard(name: Storyboard.articles, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "ArticleWebViewControllerID") as! ArticleWebViewController
    }

    
    var data: ArticleData?
    var webView: WKWebView!
    
    
    override var screenTitle: String {
        return data?.title ?? super.screenTitle
    }
    override func screenName() -> String {
        return "Article : \(screenTitle)"
    }
    override func siteSubSection() -> String {
        return "article"
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
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        webView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        if let url = data?.local {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }

//  If you need to add viewport width this is the first way...
//        var scriptContent = "var meta = document.createElement('meta');"
//        scriptContent += "meta.name='viewport';"
//        scriptContent += "meta.content='width=device-width';"
//        scriptContent += "document.getElementsByTagName('head')[0].appendChild(meta);"
//
//        webView.evaluateJavaScript(scriptContent, completionHandler: nil)
    }
    
    
    override func configureNavigationButtons() {
        if data?.canonical != nil {
            self.addShareButton()
        }
    }
    
    override func shareButtonAction() {
        let shareMessage = buildShareURLString(data?.canonical)
        
        let activityController = UIActivityViewController(activityItems: [shareMessage as Any], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
        
        let userInfo: [String: Any] = ["action": AdobeAnalyticsConstants.Values.share,
                                       AdobeAnalyticsConstants.Keys.shareAction: 1,
                                       GTConstants.kAnalyticsScreenNameKey: screenName()]
        NotificationCenter.default.post(name: .actionTrackNotification,
                                        object: nil,
                                        userInfo: userInfo)
        self.sendScreenViewNotification(screenName: screenName(), siteSection: siteSection(), siteSubSection: siteSubSection())
    }
    
    private func buildShareURLString(_ urlString: String?) -> String? {
        var us = urlString
        while us?.last! == "/" {
            us?.removeLast()
        }
        if us == nil || us?.count == 0 {
            us = "https://everystudent.com"
        }
        return us?.appending("?icid=gtshare")
    }
}

// This is the second way...
// Don't forget to add...
//         webView.navigationDelegate = self
// ... in viewDidLoad

//extension ArticleWebViewController: WKNavigationDelegate {
//
//    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//        var scriptContent = "var meta = document.createElement('meta');"
//        scriptContent += "meta.name='viewport';"
//        scriptContent += "meta.content='width=device-width';"
//        scriptContent += "document.getElementsByTagName('head')[0].appendChild(meta);"
//        webView.evaluateJavaScript(scriptContent, completionHandler: nil)
//    }
//}
