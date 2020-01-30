//
//  OnboardingTutorialUsageCell.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class OnboardingTutorialUsageCell: UITableViewCell {
    
    static let nibName: String = "OnboardingTutorialUsageCell"
    static let reuseIdentifier: String = "OnboardingTutorialUsageCellReuseIdentifier"
    
    @IBOutlet weak private var messageLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = nil
    }
    
    func configure(viewModel: OnboardingTutorialUsageCellViewModel) {
        messageLabel.text = viewModel.message
        messageLabel.setLineSpacing(lineSpacing: 2)
    }
}
