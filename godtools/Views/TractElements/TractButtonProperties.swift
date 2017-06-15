//
//  TractButtonProperties.swift
//  godtools
//
//  Created by Devserker on 5/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractButtonProperties: TractProperties {
    
    enum ButtonType {
        case url, event
    }
    
    // MARK: - XML Properties
    
    var type: ButtonType = .url
    var buttonEvents: String?
    var url: String?
    var color = UIColor.gtBlack
    
    override func defineProperties() {
        self.properties = ["type", "events", "url", "color"]
    }
    
    override func customProperties() -> [String]? {
        return ["events", "type"]
    }
    
    override func performCustomProperty(propertyName: String, value: String) {
        switch propertyName {
        case "type":
            setupType(value)
        case "events":
            setupButtonEvents(kind: value)
        default: break
        }
    }
    
    private func setupType(_ type: String) {
        switch type {
        case "url":
            self.type = .url
        case "event":
            self.type = .event
        default: break
        }
    }
    
    func setupButtonEvents(kind: String) {
        self.buttonEvents = kind
    }
    
    // MARK: - View Properties
    
    var i18nId: String?
    var value: String?
    var cornerRadius: CGFloat = 5.0
    var backgroundColor = UIColor.gtBlue
    var font = UIFont.gtRegular(size: 15.0)
    var width: CGFloat = 300.0
    var height: CGFloat = 44.0
    var xMargin = BaseTractElement.xMargin
    var yMargin = BaseTractElement.yMargin
    
    override func getTextProperties() -> TractTextContentProperties {
        let textProperties = TractTextContentProperties()
        
        textProperties.font = .gtRegular(size: 18.0)
        textProperties.width = self.width
        textProperties.textAlign = .center
        textProperties.textColor = self.color
        
        return textProperties
    }
    
}
