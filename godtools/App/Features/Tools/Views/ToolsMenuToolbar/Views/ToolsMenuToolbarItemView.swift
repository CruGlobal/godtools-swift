//
//  ToolsMenuToolbarItemView.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class ToolsMenuToolbarItemView: UICollectionViewCell {
    
    static let nibName: String = "ToolsMenuToolbarItemView"
    static let reuseIdentifier: String = "ToolsMenuToolbarItemViewReuseIdentifier"
    
    private var viewModel: ToolsMenuToolbarItemViewModelType?
    
    @IBOutlet weak private var itemImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        itemImageView.image = nil
        titleLabel.text = ""
        viewModel = nil
    }
    
    func configure(viewModel: ToolsMenuToolbarItemViewModelType) {
        
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.title
    }
}
