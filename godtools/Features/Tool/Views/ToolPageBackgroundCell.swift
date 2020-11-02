//
//  ToolPageBackgroundCell.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageBackgroundCell: UICollectionViewCell {
    
    static let nibName: String = "ToolPageBackgroundCell"
    static let reuseIdentifier: String = "ToolPageBackgroundCellReuseIdentifier"
         
    private var viewModel: ToolBackgroundCellViewModel?
    
    @IBOutlet weak private var backgroundImageView: UIImageView!
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        backgroundImageView.backgroundColor = .clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundImageView.image = nil
        viewModel = nil
    }
    
    func configure(viewModel: ToolBackgroundCellViewModel) {
        
        self.viewModel = viewModel
        
        backgroundImageView.image = viewModel.backgroundImage
    }
}
