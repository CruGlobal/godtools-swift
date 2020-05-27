//
//  FavoritedToolsView.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class FavoritedToolsView: UIView, NibBased {
    
    private var viewModel: FavoritedToolsViewModelType?
    
    @IBOutlet weak private var toolsView: ToolsTableView!
    
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
    
    func configure(viewModel: FavoritedToolsViewModelType) {
        
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
        
    }
}
