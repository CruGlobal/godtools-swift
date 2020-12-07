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
        toolPage?.removeFromSuperview()
        toolPage = nil
    }
    
    func configure(viewModel: ToolPageViewModelType, windowViewController: UIViewController, safeArea: UIEdgeInsets) {
        
        let toolPage: ToolPageView = ToolPageView(
            viewModel: viewModel,
            windowViewController: windowViewController,
            safeArea: safeArea
        )
        contentView.addSubview(toolPage)
        toolPage.constrainEdgesToSuperview()
                
        self.toolPage = toolPage
        self.viewModel = viewModel
    }
}
