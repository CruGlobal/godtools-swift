//
//  ManifestProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/9/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class ManifestProperties: XMLNode {
    
    var navBarColor = GTAppDefaultColors.navBarColor.getRGBAColor()
    var navBarControlColor = GTAppDefaultColors.navBarControlColor.getRGBAColor()
    var primaryColor = GTAppDefaultColors.primaryColor.getRGBAColor()
    var primaryTextColor = GTAppDefaultColors.primaryTextColorString.getRGBAColor()
    var textColor = GTAppDefaultColors.textColorString.getRGBAColor()
    
    func getTractColors() -> TractColors {
        return TractColors(navBarColor: self.navBarColor,
                           navBarControlColor: self.navBarControlColor,
                           primaryColor: self.primaryColor,
                           primaryTextColor: self.primaryTextColor,
                           textColor: self.textColor)
    }
    
}
