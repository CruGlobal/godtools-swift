//
//  ManifestProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/9/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class ManifestProperties: TractProperties {
    
    var backgroundColor = GTAppDefaultStyle.backgroundColorString.getRGBAColor()
    var backgroundImage: UIImage?
    var backgroundImageAlign: [TractImageConfig.ImageAlign] = [.center]
    var backgroundImageScaleType: TractImageConfig.ImageScaleType = .fill
    var navBarColor = GTAppDefaultStyle.navBarColor.getRGBAColor()
    var navBarControlColor = GTAppDefaultStyle.navBarControlColor.getRGBAColor()
    
}
