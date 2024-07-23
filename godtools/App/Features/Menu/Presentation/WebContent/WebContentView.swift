//
//  WebContentView.swift
//  godtools
//
//  Created by Levi Eggert on 4/7/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import WebKit

class WebContentView: AppViewController {
    
    private let viewModel: WebContentViewModel
    private let webView: WKWebView = WKWebView(frame: UIScreen.main.bounds)
    private let screenAccessibility: AccessibilityStrings.Screen?
    
    @IBOutlet weak private var loadingView: UIActivityIndicatorView!
        
    init(viewModel: WebContentViewModel, navigationBar: AppNavigationBar?, screenAccessibility: AccessibilityStrings.Screen?) {
        
        self.viewModel = viewModel
        self.screenAccessibility = screenAccessibility
        
        super.init(nibName: String(describing: WebContentView.self), bundle: nil, navigationBar: navigationBar)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view didload: \(type(of: self))")
        
        if let screenAccessibility = screenAccessibility {
            addScreenAccessibility(screenAccessibility: screenAccessibility)
        }
        
        setupLayout()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.pageViewed()
    }
    
    private func setupLayout() {
        
        // loadingView
        loadingView.startAnimating()
        
        // webView
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.constrainEdgesToView(view: view)
        webView.alpha = 0
        webView.scrollView.showsVerticalScrollIndicator = true
        webView.scrollView.showsHorizontalScrollIndicator = false
    }
    
    private func setupBinding() {
        
        viewModel.navTitle.addObserver(self) { [weak self] (navTitle: String) in
            self?.title = navTitle
        }
        
        viewModel.url.addObserver(self) { [weak self] (url: URL?) in
            if let url = url {
                self?.webView.navigationDelegate = self
                self?.webView.load(URLRequest(url: url))
            }
        }
    }
    
    private func finishedLoadingWebView() {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.webView.alpha = 1
        }) { [weak self] ( _) in
            self?.loadingView.stopAnimating()
        }
    }
}

extension WebContentView: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
                
        finishedLoadingWebView()
    }
}
