//
//  ArticleCategoryCell.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ArticleCategoryCell: UITableViewCell {
    
    static let nibName: String = "ArticleCategoryCell"
    static let reuseIdentifier: String = "ArticleCategoryCellReuseIdentifier"
    
    private var viewModel: ArticleCategoryCellViewModel?
    
    @IBOutlet weak private var articleImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
    
    func configure(viewModel: ArticleCategoryCellViewModel) {
        
        self.viewModel = viewModel
        
        selectionStyle = .none
        backgroundColor = .lightGray
        
        viewModel.articleImage.addObserver(self) { [weak self] (image: UIImage?) in
            self?.articleImageView.image = image
        }
        
        viewModel.title.addObserver(self) { [weak self] (title: String?) in
            self?.titleLabel.text = title
        }
    }
}
