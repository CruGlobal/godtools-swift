//
//  MenuTableViewCell.swift
//  godtools
//
//  Created by Devserker on 4/25/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {
    
    static let nibName: String = "MenuCell"
    static let reuseIdentifier: String = "MenuCellReuseIdentifier"
    
    var value = ""
        
    @IBOutlet weak private var settingLabel: GTLabel!
    @IBOutlet weak private var rightArrowImageView: UIImageView!
    @IBOutlet weak private var separatorLine: UIView!
    
    override func layoutSubviews() {
        settingLabel.text = value.localized
    }
}
