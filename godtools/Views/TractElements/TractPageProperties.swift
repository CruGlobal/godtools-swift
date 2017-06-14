//
//  TractPageProperties.swift
//  godtools
//
//  Created by Devserker on 5/29/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractPageProperties: TractProperties {
    
    // MARK: - XML Properties
    
    // primaryColor
    // primaryTextColor
    // textColor
    var backgroundColor = GTAppDefaultStyle.backgroundColorString.getRGBAColor()
    var backgroundImage: UIImage?
    var backgroundImageAlign: [TractImageConfig.ImageAlign] = [.center]
    var backgroundImageScaleType: TractImageConfig.ImageScaleType = .fill
    var cardTextColor: UIColor?
    var cardBackgroundColor: UIColor?
    var listeners: String?
    
    override func defineProperties() {
        self.properties = ["backgroundColor", "backgroundImage", "backgroundImageAlign",
                           "backgroundImageScaleType", "cardTextColor", "cardBackgroundColor",
                           "listeners"]
    }

}
