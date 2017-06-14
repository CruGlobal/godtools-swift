//
//  ManifestProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/9/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class ManifestProperties: TractProperties {
    
    var primaryColor = GTAppDefaultStyle.primaryColor.getRGBAColor()
    var primaryTextColor = GTAppDefaultStyle.primaryTextColorString.getRGBAColor()
    var textColor = GTAppDefaultStyle.textColorString.getRGBAColor()
    var backgroundColor = GTAppDefaultStyle.backgroundColorString.getRGBAColor()
    var backgroundImage: UIImage?
    var backgroundImageAlign: [TractImageConfig.ImageAlign] = [.center]
    var backgroundImageScaleType: TractImageConfig.ImageScaleType = .fill
    var navBarColor = GTAppDefaultStyle.navBarColor.getRGBAColor()
    var navBarControlColor = GTAppDefaultStyle.navBarControlColor.getRGBAColor()
    
    func getTextProperties() -> TractTextContentProperties {
        return TractTextContentProperties()
    }
    
}
