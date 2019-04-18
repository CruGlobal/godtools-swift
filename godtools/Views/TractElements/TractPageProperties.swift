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
    @objc var backgroundColor = GTAppDefaultStyle.backgroundPageColorString.getRGBAColor()
    @objc var backgroundImage: String = ""
    var backgroundImageAlign: [TractImageConfig.ImageAlign] = [.center]
    var backgroundImageScaleType: TractImageConfig.ImageScaleType = .fillX
    @objc var cardTextColor: UIColor?
    @objc var cardBackgroundColor: UIColor?
    @objc var listeners: String = ""  {
        willSet {
            print()
        }
    }
    
    override func defineProperties() {
        self.properties = ["cardTextColor", "cardBackgroundColor", "listeners"]
    }
    
    override func customProperties() -> [String]? {
        return ["backgroundImageAlign", "backgroundImageScaleType"]
    }
    
    override func performCustomProperty(propertyName: String, value: String) {
        switch propertyName {
        case "backgroundImageAlign":
            setupImageAligns(kind: value)
        case "backgroundImageScaleType":
            setupImageScaleType(kind: value)
        default: break
        }
    }
    
    func setupImageAligns(kind: String) {
        var items: [TractImageConfig.ImageAlign] = []
        
        for value in kind.components(separatedBy: " ") {
            items.append(TractImageConfig.getImageAlignKind(string: value))
        }
        
        self.backgroundImageAlign = items
    }
    
    func setupImageScaleType(kind: String) {
        self.backgroundImageScaleType = TractImageConfig.getImageScaleType(string: kind)
    }

}
