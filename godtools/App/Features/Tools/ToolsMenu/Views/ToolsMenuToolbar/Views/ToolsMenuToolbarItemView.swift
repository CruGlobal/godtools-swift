//
//  ToolsMenuToolbarItemView.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class ToolsMenuToolbarItemView: UICollectionViewCell {
    
    private static let deselectedColor: UIColor = UIColor(red: 0.804, green: 0.804, blue: 0.804, alpha: 1)
    private static let selectedColor: UIColor = UIColor(red: 0.231, green: 0.643, blue: 0.859, alpha: 1)
    
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
    
    func configure(viewModel: ToolsMenuToolbarItemViewModelType, isSelected: Bool) {
        
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.title
        itemImageView.image = viewModel.image
        
        setItemIsSelected(itemIsSelected: isSelected)
    }
    
    private func setItemIsSelected(itemIsSelected: Bool) {
        
        let color: UIColor = itemIsSelected ? ToolsMenuToolbarItemView.selectedColor : ToolsMenuToolbarItemView.deselectedColor
        
        titleLabel.textColor = color
        itemImageView.setImageColor(color: color)
    }
}
