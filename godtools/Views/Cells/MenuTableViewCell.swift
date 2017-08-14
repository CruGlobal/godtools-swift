//
//  MenuTableViewCell.swift
//  godtools
//
//  Created by Devserker on 4/25/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

protocol MenuTableViewCellDelegate {
    func menuNextButtonWasPressed(sender: MenuTableViewCell)
}

class MenuTableViewCell: UITableViewCell {
    
    var value = ""
    var isSwitchCell = false
    
    var delegate: MenuTableViewCellDelegate?
    
    @IBOutlet weak var settingLabel: GTLabel!
    @IBOutlet weak var settingSwitch: GTSwitch!
    @IBOutlet weak var nextButton: UIButton!
    
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
        self.settingLabel.text = self.value.localized
        if self.isSwitchCell {
            self.nextButton.isHidden = true
            self.settingSwitch.isHidden = false
        }
        else {
            self.nextButton.isHidden = false
            self.settingSwitch.isHidden = true
        }
    }
    
}
