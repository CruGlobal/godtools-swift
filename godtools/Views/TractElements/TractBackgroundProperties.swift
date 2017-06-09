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
    
    override func customProperties() -> [String]? {
        return ["type", "backgroundImageAlign"]
    }
    
    override func performCustomProperty(propertyName: String, value: String) {
        switch propertyName {
        case "backgroundImageScaleType":
            setupBackgroundImageScaleType(value)
        case "backgroundImageAlign":
            setupBackgroundImageAlign(value)
        default: break
        }
    }
    
    func setupBackgroundImageScaleType(_ string: String) {
        switch string {
        case "fit":
            self.backgroundImageScaleType = .fit
        case "fill":
            self.backgroundImageScaleType = .fill
        case "fill-x":
            self.backgroundImageScaleType = .fillX
        case "fill-y":
            self.backgroundImageScaleType = .fillY
        default:
            self.backgroundImageScaleType = .fit
        }
    }
    
    func setupBackgroundImageAlign(_ string: String) {
        for value in string.components(separatedBy: " ") {
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
    }
    
}
