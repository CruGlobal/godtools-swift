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
     
    private let toolPage: ToolPageView = ToolPageView()
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(toolPage)
        toolPage.constrainEdgesToSuperview()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        toolPage.resetView()
    }
    
    func configure(viewModel: ToolPageViewModelType, windowViewController: UIViewController, safeArea: UIEdgeInsets) {
        
        toolPage.configure(
            viewModel: viewModel,
            windowViewController: windowViewController,
            safeArea: safeArea
        )
    }
}
