//
//  ArticleWebView.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import WebKit

class ArticleWebView: AppViewController {
    
    private let viewModel: ArticleWebViewModel
        
    private var webView: WKWebView!
    private var currentViewState: ArticleWebViewState?
    
    @IBOutlet weak private var loadingView: UIActivityIndicatorView!
    @IBOutlet weak private var errorMessageView: UIView!
    @IBOutlet weak private var errorTitleLabel: UILabel!
    @IBOutlet weak private var errorMessageLabel: UILabel!
    @IBOutlet weak private var reloadArticleButton: UIButton!
        
    init(viewModel: ArticleWebViewModel, navigationBar: AppNavigationBar?) {
        
        self.webView = WKWebView(frame: UIScreen.main.bounds)
        self.viewModel = viewModel
        
        super.init(nibName: String(describing: ArticleWebView.self), bundle: nil, navigationBar: navigationBar)
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
        
        viewModel.loadWebPage(webView: webView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pageViewed()
    }
    
    private func setupLayout() {
        
        // loadingView
        loadingView.stopAnimating()
        
        // errorMessageView
        setErrorViewHidden(hidden: true)
        
        // webView
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.constrainEdgesToView(view: view)
        webView.alpha = 0
        webView.scrollView.showsVerticalScrollIndicator = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        // reloadArticleButton
        reloadArticleButton.addTarget(
            self,
            action: #selector(reloadArticleButtonTapped),
            for: .touchUpInside
        )
    }
    
    private func setupBinding() {
        
        viewModel.navTitle.addObserver(self) { [weak self] (navTitle: String) in
            self?.title = navTitle
        }
        
        viewModel.viewState.addObserver(self) { [weak self] (viewState: ArticleWebViewState) in
            self?.setViewState(viewState: viewState)
        }
    }
    
    private func setViewState(viewState: ArticleWebViewState) {
        
        if let currentViewState = self.currentViewState {
            
            switch currentViewState {
                
            case .errorMessage( _,  _):
                errorTitleLabel.text = ""
                errorMessageLabel.text = ""
                setErrorViewHidden(hidden: true)
                
            case .loadingArticle:
                loadingView.stopAnimating()
                
            case .viewingArticle:
                webView.alpha = 0
            }
        }
        
        currentViewState = viewState
        
        switch viewState {
            
        case .errorMessage(let title, let message):
            errorTitleLabel.text = title
            errorMessageLabel.text = message
            setErrorViewHidden(hidden: false)
            
        case .loadingArticle:
            loadingView.startAnimating()
            
        case .viewingArticle:
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.webView.alpha = 1
            }, completion: nil)
        }
    }
    
    private func setErrorViewHidden(hidden: Bool) {
        errorMessageView.isHidden = hidden
        reloadArticleButton.isHidden = hidden
    }
    
    @objc private func reloadArticleButtonTapped() {
        viewModel.reloadArticleTapped(webView: webView)
    }
}
