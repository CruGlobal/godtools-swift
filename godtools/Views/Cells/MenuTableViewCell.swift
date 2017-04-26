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
    var kind = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        self.textLabel?.text = self.value.localized
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
