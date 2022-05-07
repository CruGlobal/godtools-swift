//
//  AllToolsView.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class AllToolsView: UIViewController, ToolsMenuPageView {
    
    private let viewModel: AllToolsViewModelType
            
    @IBOutlet weak private var favoritingToolMessageView: FavoritingToolMessageView!
    @IBOutlet weak private var toolsView: ToolsTableView!
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak private var loadingView: UIActivityIndicatorView!
    
    @IBOutlet weak private var favoritingToolMessageViewTop: NSLayoutConstraint!
    
    required init(viewModel: AllToolsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: AllToolsView.self), bundle: nil)
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
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
        toolsView.configure(viewModel: viewModel)
        
        let favoritingToolMessageViewModel = viewModel.favoritingToolMessageWillAppear()
        favoritingToolMessageView.configure(viewModel: favoritingToolMessageViewModel)
        
        favoritingToolMessageViewModel.hidesMessage.addObserver(self) { [weak self] (animatableValue: AnimatableValue<Bool>) in
            self?.setFavoritingToolMessageHidden(animatableValue.value, animated: animatableValue.animated)
        }
        
        viewModel.message.addObserver(self, onObserve: { [weak self] (message: String) in
            self?.messageLabel.isHidden = message.isEmpty
            self?.messageLabel.text = message
        })
        
        viewModel.isLoading.addObserver(self) { [weak self] (isLoading: Bool) in
            isLoading ? self?.loadingView.startAnimating() : self?.loadingView.stopAnimating()
        }
    }
    
    private func setFavoritingToolMessageHidden(_ hidden: Bool, animated: Bool) {
                
        favoritingToolMessageViewTop.constant = hidden ? (favoritingToolMessageView.frame.size.height * -1) : 0
        
        if animated {
            if !hidden {
                favoritingToolMessageView.isHidden = false
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: {(finished: Bool) in
                    if hidden {
                        self.favoritingToolMessageView.isHidden = true
                    }
            })
        }
        else {
            favoritingToolMessageView.isHidden = hidden
            view.layoutIfNeeded()
        }
    }
    
    func pageViewed() {
        
        viewModel.pageViewed()
    }
    
    func scrollToTop(animated: Bool) {
        
        toolsView.scrollToTopOfTools(animated: animated)
    }
}
