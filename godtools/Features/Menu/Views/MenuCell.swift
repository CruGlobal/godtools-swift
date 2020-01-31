//
//  MenuTableViewCell.swift
//  godtools
//
//  Created by Devserker on 4/25/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

protocol MenuTableViewCellDelegate {
    func menuNextButtonWasPressed(sender: MenuCell)
}

class MenuCell: UITableViewCell {
    
    static let nibName: String = "MenuCell"
    static let reuseIdentifier: String = "MenuCellReuseIdentifier"
    
    var value = ""
    var isSwitchCell = false
    
    var delegate: MenuTableViewCellDelegate?
    
    @IBOutlet weak private var settingLabel: GTLabel!
    @IBOutlet weak private var settingSwitch: GTSwitch!
    @IBOutlet weak private var nextButton: UIButton!
    @IBOutlet weak private var separatorLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func nextButtonWasPressed(_ sender: Any) {
        delegate?.menuNextButtonWasPressed(sender: self)
    }
    
    override func layoutSubviews() {
        settingLabel.text = value.localized
        if isSwitchCell {
            nextButton.isHidden = true
            settingSwitch.isHidden = false
        }
        else {
            nextButton.isHidden = false
            settingSwitch.isHidden = true
        }
    }
}
