//
//  ArticleCell.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {
    
    static let nibName: String = "ArticleCell"
    static let reuseIdentifier: String = "ArticleCellReuseIdentifier"
    
    private var viewModel: ArticleCellViewModel?
    
    @IBOutlet weak private var titleLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
        titleLabel.text = ""
    }
    
    func configure(viewModel: ArticleCellViewModel) {
        
        self.viewModel = viewModel
        
        selectionStyle = .none
        
        titleLabel.text = viewModel.title
    }
}
