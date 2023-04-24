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
    
    private let viewModel: ArticleWebViewModel
        
    private var webView: WKWebView!
    private var shareButton: UIBarButtonItem?
    private var debugButton: UIBarButtonItem?
    private var rightBarButtonItems: [UIBarButtonItem] = Array()
    
    @IBOutlet weak private var loadingView: UIActivityIndicatorView!
        
    required init(viewModel: ArticleWebViewModel) {
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pageViewed()
    }
    
    private func setupLayout() {
        
        // right bar button items
        let shareButton: UIBarButtonItem = addBarButtonItem(
            to: .right,
            image: ImageCatalog.navShare.uiImage,
            color: .white,
            target: self,
            action: #selector(shareButtonTapped)
        )
        
        self.shareButton = shareButton
                
        let debugButton: UIBarButtonItem = addBarButtonItem(
            to: .right,
            image: ImageCatalog.navDebug.uiImage,
            color: .white,
            target: self,
            action: #selector(debugButtonTapped)
        )
        
        self.debugButton = debugButton
        
        rightBarButtonItems = [shareButton, debugButton]
        removeRightBarButtonItems()
        
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
        
        viewModel.hidesShareButton.addObserver(self) { [weak self] (hidesShareButton) in
            self?.reloadRightBarButtonItems()
        }
        
        viewModel.hidesDebugButton.addObserver(self) { [weak self] (hidesDebugButton: Bool) in
            self?.reloadRightBarButtonItems()
        }
        
        viewModel.isLoading.addObserver(self) { [weak self] (isLoading: Bool) in
            
            if isLoading {
                self?.webView.alpha = 0
                self?.loadingView.startAnimating()
            }
            else {
                self?.loadingView.stopAnimating()
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self?.webView.alpha = 1
                }, completion: nil)
            }
        }
        
        viewModel.loadWebPage(webView: webView)
    }
    
    private func reloadRightBarButtonItems() {
        
        removeRightBarButtonItems()
        
        if !viewModel.hidesShareButton.value, let shareButton = self.shareButton {
            addBarButtonItem(item: shareButton, barPosition: .right)
        }
        
        if !viewModel.hidesDebugButton.value, let debugButton = self.debugButton {
            addBarButtonItem(item: debugButton, barPosition: .right)
        }
    }
    
    private func removeRightBarButtonItems() {
        for buttonItem in rightBarButtonItems {
            removeBarButtonItem(item: buttonItem)
        }
    }
    
    @objc private func debugButtonTapped() {
        viewModel.debugTapped()
    }
    
    @objc private func shareButtonTapped() {
        viewModel.sharedTapped()
    }
}
