//
//  TractCardProperties.swift
//  godtools
//
//  Created by Devserker on 5/16/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

protocol TractCardPropertiesDelegate: class {
    
    func tractCardPropertiesDidChangeCardState(properties: TractCardProperties, cardState: TractCardProperties.CardState)
}

class TractCardProperties: TractProperties {
    
    enum CardState {
        case open, preview, close, hidden, enable
    }
    
    weak var delegate: TractCardPropertiesDelegate?
    
    // MARK: - XML Properties
    
    @objc var backgroundColor: UIColor? // may be nil, in which case background color must be fetched from parent
    @objc var backgroundImage: String = ""
    var backgroundImageAlign: [TractImageConfig.ImageAlign] = [.center]
    var backgroundImageScaleType: TractImageConfig.ImageScaleType = .fillX
    // textColor
    @objc var hidden = false
    @objc var listeners: String = ""
    @objc var dismissListeners: String = ""
    
    override func defineProperties() {
        self.properties = ["backgroundColor", "backgroundImage", "hidden", "listeners", "dismissListeners"]
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
    
    var cardNumber = 0
    var cardLetterName = ""
    var analyticEventProperties: [TractAnalyticEvent] = []
    
    var cardState: TractCardProperties.CardState = CardState.preview {
        
        didSet {
            delegate?.tractCardPropertiesDidChangeCardState(properties: self, cardState: cardState)
        }
    }
}
