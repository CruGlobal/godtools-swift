//
//  TractMainStyle.swift
//  godtools
//
//  Created by Pablo Marti on 6/13/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractMainStyle: XMLNode {
    
    enum BackgroundImageAlign {
        case center, start, end, top, bottom
    }
    
    enum BackgroundImageScaleType {
        case fit, fill, fillX, fillY
    }
    
    // MARK: - XML Properties
    
    var primaryColor = GTAppDefaultStyle.primaryColor.getRGBAColor()
    var primaryTextColor = GTAppDefaultStyle.primaryTextColorString.getRGBAColor()
    var textColor = GTAppDefaultStyle.textColorString.getRGBAColor()
    var backgroundColor = GTAppDefaultStyle.backgroundColorString.getRGBAColor()
    var backgroundImage: UIImage?
    var backgroundImageAlign: [BackgroundImageAlign] = [.center]
    var backgroundImageScaleType: BackgroundImageScaleType = .fill
    
    static func getImageAlignKind(string: String) -> TractMainStyle.BackgroundImageAlign{
        switch string {
        case "center":
            return .center
        case "start":
            return .start
        case "end":
            return .end
        case "top":
            return .top
        case "bottom":
            return .bottom
        default:
            return .center
        }
    }
    
    static func getImageScaleType(string: String) -> TractMainStyle.BackgroundImageScaleType{
        switch string {
        case "fit":
            return .fit
        case "fill":
            return .fill
        case "fill-x":
            return .fillX
        case "fill-y":
            return .fillY
        default:
            return .fill
        }
    }

}
