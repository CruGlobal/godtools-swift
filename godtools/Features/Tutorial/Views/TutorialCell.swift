//
//  TutorialCell.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TutorialCell: UICollectionViewCell {
    
    static let nibName: String = "TutorialCell"
    static let reuseIdentifier: String = "TutorialCellReuseIdentifier"
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak private var mainImageView: UIImageView!
    
    func configure(viewModel: TutorialCellViewModel) {
        titleLabel.text = viewModel.title
        messageLabel.text = viewModel.message
        messageLabel.setLineSpacing(lineSpacing: 2)
    }
}
