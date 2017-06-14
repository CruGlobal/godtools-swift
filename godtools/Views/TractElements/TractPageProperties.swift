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
    
    var primaryColor = GTAppDefaultStyle.primaryColor.getRGBAColor()
    var primaryTextColor = GTAppDefaultStyle.primaryTextColorString.getRGBAColor()
    var textColor = GTAppDefaultStyle.textColorString.getRGBAColor()
    var backgroundColor = GTAppDefaultStyle.backgroundColorString.getRGBAColor()
    var backgroundImage: UIImage?
    var backgroundImageAlign: [TractImageConfig.ImageAlign] = [.center]
    var backgroundImageScaleType: TractImageConfig.ImageScaleType = .fill
    var cardTextColor: UIColor?
    var cardBackgroundColor: UIColor?
    var listeners: String?
    
    override func properties() -> [String]? {
        return ["primaryColor", "primaryTextColor", "textColor", "backgroundColor", "backgroundImage", "backgroundImageAlign",
        "backgroundImageScaleType", "cardTextColor", "cardBackgroundColor", "listeners"]
    }

}
