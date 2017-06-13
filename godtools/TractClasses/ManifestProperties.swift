//
//  ManifestProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/9/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class ManifestProperties: XMLNode {
    
    var primaryColor = GTAppDefaultStyle.primaryColor.getRGBAColor()
    var primaryTextColor = GTAppDefaultStyle.primaryTextColorString.getRGBAColor()
    var textColor = GTAppDefaultStyle.textColorString.getRGBAColor()
    var backgroundColor = GTAppDefaultStyle.backgroundColorString.getRGBAColor()
    var backgroundImage: UIImage?
    var backgroundImageAlign: [TractMainStyle.BackgroundImageAlign] = [.center]
    var backgroundImageScaleType: TractMainStyle.BackgroundImageScaleType = .fill
    var navBarColor = GTAppDefaultStyle.navBarColor.getRGBAColor()
    var navBarControlColor = GTAppDefaultStyle.navBarControlColor.getRGBAColor()
    
}
