//
//  MenuTableViewCell.swift
//  godtools
//
//  Created by Devserker on 4/25/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    var value = ""
    var isSwitchCell = false

    @IBOutlet weak var settingLabel: GTLabel!
    @IBOutlet weak var settingSwitch: GTSwitch!
    @IBOutlet weak var nextButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .gtGreyLight
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
