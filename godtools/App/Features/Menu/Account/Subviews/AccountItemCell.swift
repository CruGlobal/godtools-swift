//
//  AccountItemCell.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol AccountItemCellDelegate: AnyObject {
    
    func accountItemCellDidProcessAlertMessage(cell: AccountItemCell, alertMessage: AlertMessageType)
}

class AccountItemCell: UICollectionViewCell {
    
    static let nibName: String = "AccountItemCell"
    static let reuseIdentifier: String = "AccountItemCellReuseIdentifier"
    
    private weak var delegate: AccountItemCellDelegate?
    
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
    
    func configure(viewModel: AccountItemCellViewModel, delegate: AccountItemCellDelegate?) {
            
        self.delegate = delegate
        
        clearItemParentView()
        
        let itemView: AccountItemViewType = viewModel.itemView
        
        itemParentView.addSubview(itemView)
        itemView.frame = itemParentView.bounds
        itemView.translatesAutoresizingMaskIntoConstraints = false
        itemView.constrainEdgesToView(view: itemParentView)
        itemView.delegate = self
    }
}

// MARK: - AccountItemViewDelegate

extension AccountItemCell: AccountItemViewDelegate {
    func accountItemViewDidProcessAlertMessage(itemView: AccountItemViewType, alertMessage: AlertMessageType) {
        delegate?.accountItemCellDidProcessAlertMessage(cell: self, alertMessage: alertMessage)
    }
}
