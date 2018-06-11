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
    var events: String = ""
    var url: String = ""
    var buttonColor: UIColor?
    var analyticsButtonUserInfo: [String: String] = [:]
    
    override func defineProperties() {
        self.properties = ["events", "url"]
    }
    
    override func customProperties() -> [String]? {
        return ["type", "color"]
    }
    
    override func performCustomProperty(propertyName: String, value: String) {
        switch propertyName {
        case "type":
            setupType(value)
        case "color":
            self.buttonColor = value.getRGBAColor()
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
        
        return textProperties
    }
    
}
