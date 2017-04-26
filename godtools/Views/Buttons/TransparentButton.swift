//
//  TransparentButton.swift
//  godtools
//
//  Created by Devserker on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TransparentButton: GTButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.cornerRadius = 5.0
        self.borderColor = UIColor.gtWhite
        self.borderWidth = 1.0
        self.backgroundColor = UIColor.clear
        self.color = UIColor.gtWhite
        self.titleLabel?.font = UIFont.gtRegular(size: 15.0)
    }

}
