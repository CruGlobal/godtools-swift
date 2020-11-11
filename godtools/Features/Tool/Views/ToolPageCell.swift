//
//  ToolPageCell.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageCell: UICollectionViewCell {
    
    static let nibName: String = "ToolPageCell"
    static let reuseIdentifier: String = "ToolPageCellReuseIdentifier"
     
    private var toolPage: ToolPageView?
    private var viewModel: ToolPageViewModelType?
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewModel = nil
        toolPage?.view.removeFromSuperview()
        toolPage = nil
    }
    
    func configure(viewModel: ToolPageViewModelType, safeAreaInsets: UIEdgeInsets) {
        
        let toolPage: ToolPageView = ToolPageView(viewModel: viewModel, safeAreaInsets: safeAreaInsets)
        contentView.addSubview(toolPage.view)
        toolPage.view.constrainEdgesToSuperview()
                
        self.toolPage = toolPage
        self.viewModel = viewModel
    }
}
