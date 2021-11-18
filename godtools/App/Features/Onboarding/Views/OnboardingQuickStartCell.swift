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
    @IBOutlet weak private var linkButton: UIButton!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        setupLayout()
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        titleLabel.text = nil
        linkButton.setTitle(nil, for: .normal)
    }
    
    func configure(item: OnboardingQuickStartItem) {
        
        self.item = item
        
        titleLabel.text = item.title
        linkButton.setTitle(item.linkButtonTitle, for: .normal)
    }
    
    private func setupLayout() {
        
        guard let buttonImage = UIImage(named: "arrow.forward") else  {
            return
        }
        
        linkButton.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        
        linkButton.setImage(buttonImage, for: .normal)
        
        linkButton.setInsets(forContentPadding:
            UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6),
            imageTitlePadding: 10,
            iconGravity: .end
        )
    }
}
