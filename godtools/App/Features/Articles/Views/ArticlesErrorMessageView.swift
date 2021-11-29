//
//  ArticlesErrorMessageView.swift
//  godtools
//
//  Created by Levi Eggert on 5/19/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ArticlesErrorMessageViewDelegate: AnyObject {
    
    func articlesErrorMessageViewDownloadArticlesButtonTapped(articlesErrorMessageView: ArticlesErrorMessageView)
}

class ArticlesErrorMessageView: UIView, NibBased {
    
    private weak var delegate: ArticlesErrorMessageViewDelegate?
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak private var downloadArticlesButton: UIButton!
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        loadNib()
        
        downloadArticlesButton.addTarget(self, action: #selector(handleDownloadArticles(button:)), for: .touchUpInside)
    }
    
    func configure(viewModel: ArticlesErrorMessageViewModel, delegate: ArticlesErrorMessageViewDelegate?) {
        
        self.delegate = delegate
        
        titleLabel.text = viewModel.title
        messageLabel.text = viewModel.message
        downloadArticlesButton.setTitle(viewModel.downloadArticlesButtonTitle, for: .normal)
    }
    
    @objc func handleDownloadArticles(button: UIButton) {
        delegate?.articlesErrorMessageViewDownloadArticlesButtonTapped(articlesErrorMessageView: self)
    }
}
