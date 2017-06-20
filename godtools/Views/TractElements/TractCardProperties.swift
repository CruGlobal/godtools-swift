//
//  TractCardProperties.swift
//  godtools
//
//  Created by Devserker on 5/16/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractCardProperties: TractProperties {
    
    enum CardState {
        case open, preview, close, hidden, enable
    }
    
    // MARK: - XML Properties
    
    var backgroundColor: UIColor = .gtWhite
    var backgroundImage: String = ""
    var backgroundImageAlign: [TractImageConfig.ImageAlign] = [.center]
    var backgroundImageScaleType: TractImageConfig.ImageScaleType = .fill
    // textColor
    var hidden = false
    var listeners: String = ""
    
    override func defineProperties() {
        self.properties = ["backgroundColor", "backgroundImage", "hidden", "listeners"]
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
    
    // MARK: - View Properties
    
    var cardState = CardState.preview
    var cardNumber = 0
    
}
