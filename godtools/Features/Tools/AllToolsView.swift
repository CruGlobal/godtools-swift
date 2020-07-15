//
//  AllToolsView.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class AllToolsView: UIView, NibBased {
    
    private var viewModel: AllToolsViewModelType!
    private var favoritingToolMessageViewModel: FavoritingToolMessageViewModelType!
        
    @IBOutlet weak private var favoritingToolMessageView: FavoritingToolMessageView!
    @IBOutlet weak private var toolsView: ToolsTableView!
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak private var loadingView: UIActivityIndicatorView!
    
    @IBOutlet weak private var favoritingToolMessageViewTop: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fatalError("init(frame:) has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        loadNib()
                
        setupLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setFavoritingToolMessageHidden(
            favoritingToolMessageViewModel.hidesMessage.value.hidden,
            animated: false
        )
    }
    
    func configure(viewModel: AllToolsViewModelType, favoritingToolMessageViewModel: FavoritingToolMessageViewModelType) {
        
        self.viewModel = viewModel
        self.favoritingToolMessageViewModel = favoritingToolMessageViewModel
        
        toolsView.configure(viewModel: viewModel)
        
        favoritingToolMessageView.configure(viewModel: favoritingToolMessageViewModel, delegate: self)
        
        setupBinding()
    }
    
    func pageViewed() {
        viewModel?.pageViewed()
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
        favoritingToolMessageViewModel.hidesMessage.addObserver(self) { [weak self] (objectTuple: (hidden: Bool, animated: Bool)) in
            self?.setFavoritingToolMessageHidden(objectTuple.hidden, animated: objectTuple.animated)
        }
        
        viewModel.message.addObserver(self, onObserve: { [weak self] (message: String) in
            self?.messageLabel.isHidden = message.isEmpty
            self?.messageLabel.text = message
        })
        
        viewModel.isLoading.addObserver(self) { [weak self] (isLoading: Bool) in
            isLoading ? self?.loadingView.startAnimating() : self?.loadingView.stopAnimating()
        }
    }
    
    func scrollToTopOfTools(animated: Bool) {
        toolsView.scrollToTopOfTools(animated: animated)
    }
    
    private func setFavoritingToolMessageHidden(_ hidden: Bool, animated: Bool) {
                
        favoritingToolMessageViewTop.constant = hidden ? (favoritingToolMessageView.frame.size.height * -1) : 0
        
        if animated {
            if !hidden {
                favoritingToolMessageView.isHidden = false
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.layoutIfNeeded()
                }, completion: {(finished: Bool) in
                    if hidden {
                        self.favoritingToolMessageView.isHidden = true
                    }
            })
        }
        else {
            favoritingToolMessageView.isHidden = hidden
            layoutIfNeeded()
        }
    }
}

// MARK: - FavoritingToolMessageViewDelegate

extension AllToolsView: FavoritingToolMessageViewDelegate {
    
    func favoritingToolMessageCloseTapped() {
        
        setFavoritingToolMessageHidden(true, animated: true)
    }
}
