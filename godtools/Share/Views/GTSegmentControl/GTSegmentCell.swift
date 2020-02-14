//
//  GTSegmentCell.swift
//  godtools
//
//  Created by Levi Eggert on 1/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class GTSegmentCell: UICollectionViewCell {
    
    static let nibName: String = "GTSegmentCell"
    static let reuseIdentifier: String = "GTSegmentCellReuseIdentifier"
    
    @IBOutlet weak private var titleLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = bounds
    }
    
    var title: String? {
        get {
            return titleLabel.text
        }
        set(value) {
            titleLabel.text = value
        }
    }
    
    var titleColor: UIColor {
        get {
            return titleLabel.textColor
        }
        set(value) {
            titleLabel.textColor = value
        }
    }
}
