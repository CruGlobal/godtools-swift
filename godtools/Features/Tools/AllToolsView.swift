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
    
    @IBOutlet weak private var toolsView: ToolsTableView!
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak private var loadingView: UIActivityIndicatorView!
    
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
    
    func configure(viewModel: AllToolsViewModelType) {
        
        self.viewModel = viewModel
        
        toolsView.configure(viewModel: viewModel)
        
        setupBinding()
    }
    
    func pageViewed() {
        viewModel?.pageViewed()
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
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
}
