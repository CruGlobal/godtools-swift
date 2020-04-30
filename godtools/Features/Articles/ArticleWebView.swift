//
//  ArticleWebView.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import WebKit

class ArticleWebView: UIViewController {
    
    private let viewModel: ArticleWebViewModelType
        
    private var webView: WKWebView!
    private var shareButton: UIBarButtonItem?
    
    @IBOutlet weak private var loadingView: UIActivityIndicatorView!
        
    required init(viewModel: ArticleWebViewModelType) {
        self.webView = WKWebView(frame: UIScreen.main.bounds)
        self.viewModel = viewModel
        super.init(nibName: String(describing: ArticleWebView.self), bundle: nil)
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
        
        shareButton = addBarButtonItem(
            to: .right,
            image: ImageCatalog.navShare.image,
            color: .white,
            target: self,
            action: #selector(handleShare(barButtonItem:))
        )
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
        webView.constrainEdgesToSuperview()
        webView.alpha = 0
        webView.scrollView.showsVerticalScrollIndicator = true
        webView.scrollView.showsHorizontalScrollIndicator = false
    }
    
    private func setupBinding() {
        
        viewModel.navTitle.addObserver(self) { [weak self] (navTitle: String) in
            self?.title = navTitle
        }
        
        viewModel.hidesShareButton.addObserver(self) { [weak self] (hidesShareButton) in
            if let shareButton = self?.shareButton {
                let shareButtonPosition = ButtonItemPosition.right
                if hidesShareButton {
                    self?.removeBarButtonItem(item: shareButton, barPosition: shareButtonPosition)
                }
                else {
                    self?.addBarButtonItem(item: shareButton, barPosition: shareButtonPosition)
                }
            }
        }
        
        viewModel.webUrl.addObserver(self) { [weak self] (url: URL?) in
            if let url = url {
                self?.webView.navigationDelegate = self
                self?.webView.load(URLRequest(url: url))
            }
        }
        
        viewModel.webArchiveUrl.addObserver(self) { [weak self] (url: URL?) in
            if let url = url {
                self?.webView.navigationDelegate = self
                self?.webView.loadFileURL(url, allowingReadAccessTo: url)
            }
        }
    }
    
    @objc func handleShare(barButtonItem: UIBarButtonItem) {
        viewModel.sharedTapped()
    }
    
    private func finishedLoadingWebView() {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.webView.alpha = 1
        }) { [weak self] ( _) in
            self?.loadingView.stopAnimating()
        }
    }
}

extension ArticleWebView: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                
        finishedLoadingWebView()
    }
}
