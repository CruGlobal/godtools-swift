//
//  LearnToShareToolCell.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class LearnToShareToolCell: UICollectionViewCell {
    
    static let nibName: String = "LearnToShareToolCell"
    static let reuseIdentifier: String = "LearnToShareToolCellReuseIdentifier"
    
    private var viewModel: LearnToShareToolCellViewModelType?
    
    @IBOutlet weak private var featuredImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var messageTextView: UITextView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewModel = nil
    }
    
    func configure(viewModel: LearnToShareToolCellViewModelType) {
        
        self.viewModel = viewModel
        
        if let imageName = viewModel.imageName {
            featuredImageView.image = UIImage(named: imageName)
        }
        else {
            featuredImageView.image = nil
        }
        
        titleLabel.text = viewModel.title
        titleLabel.setLineSpacing(lineSpacing: 1)
        titleLabel.textAlignment = .center
        
        messageTextView.text = viewModel.message
        messageTextView.setLineSpacing(lineSpacing: 5)
        messageTextView.textAlignment = .center
    }
}
