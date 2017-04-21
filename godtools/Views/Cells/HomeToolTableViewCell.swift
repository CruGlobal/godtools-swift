//
//  HomeToolTableViewCell.swift
//  godtools
//
//  Created by Devserker on 4/20/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class HomeToolTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var greyVerticalLine: UIImageView!
    @IBOutlet weak var titleLabel: GTLabel!
    @IBOutlet weak var numberOfViewsLabel: GTLabel!
    @IBOutlet weak var languageLabel: GTLabel!
    @IBOutlet weak var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberOfViewsLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCellAsDisplayOnly() {
        self.downloadButton.isHidden = true
        self.greyVerticalLine.isHidden = true
        self.titleLeadingConstraint.constant = 8
        self.numberOfViewsLeadingConstraint.constant = 8
    }
    
    // MARK: - Actions
    
    @IBAction func pressDownloadButton(_ sender: Any) {
    }
    
    @IBAction func pressInfoButton(_ sender: Any) {
    }
    
}
