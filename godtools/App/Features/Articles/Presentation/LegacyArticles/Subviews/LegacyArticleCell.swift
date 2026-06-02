//
//  LegacyArticleCell.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class LegacyArticleCell: UITableViewCell {
    
    static let nibName: String = "LegacyArticleCell"
    static let reuseIdentifier: String = "LegacyArticleCellReuseIdentifier"
    
    private var viewModel: LegacyArticleCellViewModel?
    
    @IBOutlet weak private var titleLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
        titleLabel.text = ""
    }
    
    func configure(viewModel: LegacyArticleCellViewModel) {
        
        self.viewModel = viewModel
        
        selectionStyle = .none
        
        titleLabel.text = viewModel.title
    }
}
