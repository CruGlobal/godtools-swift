//
//  HomeToolTableViewCell.swift
//  godtools
//
//  Created by Devserker on 4/20/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

@IBDesignable
class HomeToolTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var contentTopView: UIView!
    @IBOutlet weak var contentBottomView: UIView!
    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var greyVerticalLine: UIImageView!
    @IBOutlet weak var titleLabel: GTLabel!
    @IBOutlet weak var numberOfViewsLabel: GTLabel!
    @IBOutlet weak var languageLabel: GTLabel!
    @IBOutlet weak var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberOfViewsLeadingConstraint: NSLayoutConstraint!
    @IBInspectable var leftConstraintValue: CGFloat = 8.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCellAsDisplayOnly() {
        self.downloadButton.isHidden = true
        self.greyVerticalLine.isHidden = true
        self.titleLeadingConstraint.constant = self.leftConstraintValue
        self.numberOfViewsLeadingConstraint.constant = self.leftConstraintValue
    }
    
    // MARK: - Actions
    
    @IBAction func pressDownloadButton(_ sender: Any) {
    }
    
    @IBAction func pressInfoButton(_ sender: Any) {
    }
    
    // MARK: UI 
    
    func setupUI() {
        self.selectionStyle = .none
        self.backgroundColor = .gtWhite
        self.setBorders()
        self.setShadows()
    }
    
    func setBorders() {
        let layer = borderView.layer
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.clear.cgColor
    }
    
    func setShadows() {
        self.shadowView.backgroundColor = .gtWhite
        let layer = shadowView.layer
        layer.cornerRadius = 3.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3.0
        layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        layer.shadowOpacity = 0.4
        layer.shouldRasterize = true
    }
    
}
