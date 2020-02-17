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
    
    func configure(viewModel: AccountItemCellViewModel) {
        
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
        
        contentView.addSubview(viewModel.itemView)
        viewModel.itemView.frame = contentView.bounds
        viewModel.itemView.constrainEdgesToSuperview()
    }
}
