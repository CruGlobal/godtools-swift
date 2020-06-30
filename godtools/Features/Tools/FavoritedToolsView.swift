//
//  FavoritedToolsView.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol FavoritedToolsViewDelegate: class {
    
    func favoritedToolsViewFindToolsTapped(favoritedToolsView: FavoritedToolsView)
}

class FavoritedToolsView: UIView, NibBased {
    
    private var viewModel: FavoritedToolsViewModelType!
    
    private weak var delegate: FavoritedToolsViewDelegate?
    
    @IBOutlet weak private var findToolsView: UIView!
    @IBOutlet weak private var searchImageView: UIImageView!
    @IBOutlet weak private var findToolsButton: UIButton!
    @IBOutlet weak private var toolsView: ToolsTableView!
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
        
        findToolsButton.addTarget(self, action: #selector(handleFindTools(button:)), for: .touchUpInside)
    }
    
    func configure(viewModel: FavoritedToolsViewModelType, delegate: FavoritedToolsViewDelegate) {
        
        self.viewModel = viewModel
        self.delegate = delegate
        
        toolsView.configure(viewModel: viewModel)
        
        setupBinding()
    }
    
    func pageViewed() {
        viewModel?.pageViewed()
    }
    
    private func setupLayout() {
        
        findToolsView.alpha = 0
        findToolsButton.layer.cornerRadius = 6
    }
    
    private func setupBinding() {
        
        findToolsButton.setTitle(viewModel.findToolsTitle, for: .normal)
        
        viewModel.hidesFindToolsView.addObserver(self) { [weak self] (hidesFindToolsView: Bool) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self?.findToolsView.alpha = hidesFindToolsView ? 0 : 1
            }, completion: nil)
        }
        
        viewModel.isLoading.addObserver(self) { [weak self] (isLoading: Bool) in
            isLoading ? self?.loadingView.startAnimating() : self?.loadingView.stopAnimating()
        }
    }
    
    @objc func handleFindTools(button: UIButton) {
        delegate?.favoritedToolsViewFindToolsTapped(favoritedToolsView: self)
    }
}
