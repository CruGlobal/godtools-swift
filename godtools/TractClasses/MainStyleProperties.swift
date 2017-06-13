//
//  MainStyleProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/13/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class MainStyleProperties: XMLNode {
    
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
    var textSize = 18
    var backgroundColor = GTAppDefaultStyle.backgroundColorString.getRGBAColor()
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
    
    func loadPropertiesFromObject(_ object: MainStyleProperties) {
        self.primaryColor = object.primaryColor
        self.primaryTextColor = object.primaryTextColor
        self.textColor = object.textColor
        self.textSize = object.textSize
        self.backgroundColor = object.backgroundColor
        self.backgroundImage = object.backgroundImage
        self.backgroundImageAlign = object.backgroundImageAlign
        self.backgroundImageScaleType = object.backgroundImageScaleType
        
    }

}
