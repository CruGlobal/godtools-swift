//
//  OnboardingQuickStartCell.swift
//  godtools
//
//  Created by Robert Eldredge on 11/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class OnboardingQuickStartCell: UITableViewCell {
    
    static let nibName: String = "OnboardingQuickStartCell"
    static let reuseIdentifier: String = "OnboardingQuickStartCellReuseIdentifier"
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
    
    func configure(item: OnboardingQuickStartCellViewModelType) {
        
        titleLabel.text = item.title
        subtitleLabel.text = item.linkButtonTitle
    }
}
