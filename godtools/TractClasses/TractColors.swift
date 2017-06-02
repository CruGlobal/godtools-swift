//
//  TractColors.swift
//  godtools
//
//  Created by Devserker on 5/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractColors: NSObject {
    
    var primaryColor: UIColor?
    var primaryTextColor: UIColor?
    var textColor: UIColor?
    
    override init() {
        super.init()
    }
    
    init(primaryColor: UIColor, primaryTextColor: UIColor, textColor: UIColor) {
        self.primaryColor = primaryColor
        self.primaryTextColor = primaryTextColor
        self.textColor = textColor
    }
    
    func copyObject() -> TractColors {
        return TractColors(primaryColor: self.primaryColor!,
                           primaryTextColor: self.primaryTextColor!,
                           textColor: self.textColor!)
    }

}
