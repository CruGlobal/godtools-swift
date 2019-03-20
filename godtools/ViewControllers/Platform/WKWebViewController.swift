//
//  WKWebViewController.swift
//  godtools
//
//  Created by Igor Ostriz on 20/03/2019.
//  Copyright © 2019 Cru. All rights reserved.
//


import UIKit
import WebKit


class WKWebViewController: BaseViewController {

 
    static func create() -> WKWebViewController {
        return WKWebViewController()
    }


    var pageTitleForAnalytics: String?
    var pageTitle: String?
    var websiteUrl: URL?
    var webView: WKWebView!
    var activityIndicatorView: UIActivityIndicatorView!


    override var screenTitle: String {
        return self.pageTitle?.localized ?? super.screenTitle
    }
    override func screenName() -> String {
        return self.pageTitleForAnalytics ?? "unknown"
    }
    override func siteSection() -> String {
        return "menu"
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        // viewport responsive
        var scriptContent = "var meta = document.createElement('meta');"
        scriptContent += "meta.name='viewport';"
        scriptContent += "meta.content='width=device-width';"
        scriptContent += "document.getElementsByTagName('head')[0].appendChild(meta);"
        
        let userScript = WKUserScript(source: scriptContent, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)
        let webConfig = WKWebViewConfiguration()
//        webConfig.userContentController = contentController
        
        // cannot use storyboard for WKWebView prior to iOS 11
        webView = WKWebView(frame: view.bounds, configuration: webConfig)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        webView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // spinner
        activityIndicatorView = UIActivityIndicatorView(frame: CGRect.zero)
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = UIColor.black
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }


    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        spinnerView(on: true)
        webView.load(URLRequest(url: websiteUrl!))
    }

    
    func spinnerView(on: Bool) {
        if on == true {
            activityIndicatorView.startAnimating()
        }
        UIView.animate(withDuration: 0.35, animations: {
            self.activityIndicatorView.alpha = on ? 1.0 : 0.0
        }) { (finished) in
            if finished == true && on == false {
                self.activityIndicatorView.stopAnimating()
            }
        }
    }

}



extension WKWebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        spinnerView(on: false)
    }
}
