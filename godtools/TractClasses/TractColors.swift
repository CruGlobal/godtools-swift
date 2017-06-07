//
//  TractColors.swift
//  godtools
//
//  Created by Devserker on 5/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractColors: NSObject {
    
    var navBarColor: UIColor?
    var navBarControlColor: UIColor?
    var primaryColor: UIColor?
    var primaryTextColor: UIColor?
    var textColor: UIColor?
    
    override init() {
        super.init()
    }
    
    init(navBarColor: UIColor, navBarControlColor: UIColor, primaryColor: UIColor, primaryTextColor: UIColor, textColor: UIColor) {
        self.navBarColor = navBarColor
        self.navBarControlColor = navBarControlColor
        self.primaryColor = primaryColor
        self.primaryTextColor = primaryTextColor
        self.textColor = textColor
    }
    
    func copyObject() -> TractColors {
        return TractColors(navBarColor: self.navBarColor!,
                           navBarControlColor: self.navBarControlColor!,
                           primaryColor: self.primaryColor!,
                           primaryTextColor: self.primaryTextColor!,
                           textColor: self.textColor!)
    }

}
