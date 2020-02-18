//
//  AccountItemCell.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class AccountItemCell: UICollectionViewCell {
    
    static let nibName: String = "AccountItemCell"
    static let reuseIdentifier: String = "AccountItemCellReuseIdentifier"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clearItemParentView()
    }
    
    private var itemParentView: UIView {
        return contentView
    }
    
    private func clearItemParentView() {
        for subview in itemParentView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func configure(viewModel: AccountItemCellViewModel) {
            
        clearItemParentView()
        contentView.addSubview(viewModel.itemView)
        viewModel.itemView.frame = itemParentView.bounds
        viewModel.itemView.constrainEdgesToSuperview()
    }
}
