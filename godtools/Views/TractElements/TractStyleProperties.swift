//
//  TractStyleProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractStyleProperties: TractProperties {
    
    enum BackgroundImageAlign {
        case center, start, end, top, bottom
    }
    
    enum BackgroundImageScaleType {
        case fit, fill, fillX, fillY
    }
    
    // MARK: - XML Properties
    
    var navBarColor = GTAppDefaultColors.navBarColor.getRGBAColor()
    var navBarControlColor = GTAppDefaultColors.navBarControlColor.getRGBAColor()
    var primaryColor = GTAppDefaultColors.primaryColor.getRGBAColor()
    var primaryTextColor = GTAppDefaultColors.primaryTextColorString.getRGBAColor()
    var textColor = GTAppDefaultColors.textColorString.getRGBAColor()
    var backgroundColor: UIColor?
    var backgroundImage: UIImage?
    var backgroundImageAlign: [BackgroundImageAlign] = [.center]
    var backgroundImageScaleType: BackgroundImageScaleType = .fit
    
    // MARK: - Setup of custom properties
    
    override func customProperties() -> [String]? {
        return ["backgroundImage", "backgroundImageScaleType", "backgroundImageAlign"]
    }
    
    override func performCustomProperty(propertyName: String, value: String) {
        switch propertyName {
        case "backgroundImage":
            setupBackgroundImage(value)
        case "backgroundImageScaleType":
            setupBackgroundImageScaleType(value)
        case "backgroundImageAlign":
            setupBackgroundImageAlign(value)
        default: break
        }
    }
    
    private func setupBackgroundImage(_ string: String) {
        guard let backgroundImage = UIImage(named: string) else {
            return
        }
        self.backgroundImage = backgroundImage
    }
    
    private func setupBackgroundImageScaleType(_ string: String) {
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
    
    private func setupBackgroundImageAlign(_ string: String) {
        for value in string.components(separatedBy: " ") {
            switch value {
            case "center":
                self.backgroundImageAlign.append(.center)
            case "start":
                self.backgroundImageAlign.append(.start)
            case "end":
                self.backgroundImageAlign.append(.end)
            case "top":
                self.backgroundImageAlign.append(.top)
            case "bottom":
                self.backgroundImageAlign.append(.bottom)
            default: break
            }
        }
    }
    
    // MARK: - Management functions
    
    func overrideProperties(withProperties styleProperties: TractStyleProperties) {
        self.navBarColor = styleProperties.navBarColor
        self.navBarControlColor = styleProperties.navBarControlColor
        self.primaryColor = styleProperties.primaryColor
        self.primaryTextColor = styleProperties.primaryTextColor
        self.textColor = styleProperties.textColor
        self.backgroundColor = styleProperties.backgroundColor
        self.backgroundImage = styleProperties.backgroundImage
        self.backgroundImageAlign = styleProperties.backgroundImageAlign
        self.backgroundImageScaleType = styleProperties.backgroundImageScaleType
    }
    
}
