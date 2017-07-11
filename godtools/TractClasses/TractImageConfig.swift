//
//  TractImageConfig.swift
//  godtools
//
//  Created by Pablo Marti on 6/13/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

class TractImageConfig: NSObject {
    
    enum ImageAlign {
        case center, start, end, top, bottom
    }
    
    enum ImageScaleType {
        case fit, fill, fillX, fillY
    }
    
    static func getImageAlignKind(string: String) -> TractImageConfig.ImageAlign {
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
    
    static func getImageScaleType(string: String) -> TractImageConfig.ImageScaleType {
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
