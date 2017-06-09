//
//  TractBackgroundProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractBackgroundProperties: XMLNode {
    
    enum BackgroundImageAlign {
        case center, start, end, top, bottom
    }
    
    enum BackgroundImageScaleType {
        case fit, fill, fillX, fillY
    }
    
    var backgroundImagePath: String?
    var backgroundImageAlign: [BackgroundImageAlign]?
    var backgroundImageScaleType: BackgroundImageScaleType?
    
    override func loadCustomProperties(_ properties: [String: Any]) {        
        for property in properties.keys {
            switch property {
            case "background-image-scale-type":
                switch properties[property] as! String! {
                case "fit":
                    self.backgroundImageScaleType = .fit
                case "fill":
                    self.backgroundImageScaleType = .fill
                case "fill-x":
                    self.backgroundImageScaleType = .fillX
                case "fill-y":
                    self.backgroundImageScaleType = .fillY
                    
                default: break
                }
            case "background-image-align":
                let values = properties[property] as! String?
                for value in (values?.components(separatedBy: " "))! {
                    switch value {
                    case "center":
                        self.backgroundImageAlign?.append(.center)
                    case "start":
                        self.backgroundImageAlign?.append(.start)
                    case "end":
                        self.backgroundImageAlign?.append(.end)
                    case "top":
                        self.backgroundImageAlign?.append(.top)
                    case "bottom":
                        self.backgroundImageAlign?.append(.bottom)
                    default: break
                    }
                }
            default: break
            }
        }
    }
}
