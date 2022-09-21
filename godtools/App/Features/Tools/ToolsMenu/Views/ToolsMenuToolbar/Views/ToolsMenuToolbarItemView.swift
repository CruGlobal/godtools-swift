//
//  ToolsMenuToolbarItemView.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class ToolsMenuToolbarItemView: UICollectionViewCell {
    
    private static let deselectedColor: UIColor = UIColor(red: 170 / 255, green: 170 / 255, blue: 170 / 255, alpha: 1)
    private static let selectedColor: UIColor = UIColor(red: 59 / 255, green: 164 / 255, blue: 219 / 255, alpha: 1)
    
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
