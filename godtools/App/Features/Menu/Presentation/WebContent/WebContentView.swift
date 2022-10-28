//
//  WebContentView.swift
//  godtools
//
//  Created by Levi Eggert on 4/7/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import WebKit

class WebContentView: UIViewController {
    
    private let viewModel: WebContentViewModelType
        
    private var webView: WKWebView!
    
    @IBOutlet weak private var loadingView: UIActivityIndicatorView!
        
    required init(viewModel: WebContentViewModelType) {
        self.webView = WKWebView(frame: UIScreen.main.bounds)
        self.viewModel = viewModel
        super.init(nibName: String(describing: WebContentView.self), bundle: nil)
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
            
        setupLayout()
        setupBinding()
        
        addDefaultNavBackItem()
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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                
        finishedLoadingWebView()
    }
}
