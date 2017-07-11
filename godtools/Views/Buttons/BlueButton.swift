//
//  GTBlueButton.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class BlueButton: GTButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.cornerRadius = 5.0
        self.backgroundColor = UIColor.gtBlue
        self.color = UIColor.gtWhite
        self.titleLabel?.font = UIFont.gtRegular(size: 15.0)
    }
}
