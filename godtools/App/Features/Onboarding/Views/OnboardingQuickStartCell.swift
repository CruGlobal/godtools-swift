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
        
    private var item: OnboardingQuickStartItem?
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        setupLayout()
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
    
    func configure(item: OnboardingQuickStartItem) {
        
        self.item = item
        
        titleLabel.text = item.title
        subtitleLabel.text = item.linkButtonTitle
    }
    
    private func setupLayout() {
        
        guard let buttonImage = UIImage(named: "arrow.forward") else  {
            return
        }
    }
}
