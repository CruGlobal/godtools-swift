//
//  GTBlueButton.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class GTBlueButton: GTButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.cornerRadius = 5.0
        self.backgroundColor = GTConstants.blueColor
        self.color = GTConstants.whiteColor
    }
}
