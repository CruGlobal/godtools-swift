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
    @objc var events: String = ""
    @objc var url: String = ""
    @objc var buttonColor: UIColor?
    var analyticsButtonUserInfo: [TractAnalyticEvent] = []
    
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
    
    @objc var i18nId: String?
    @objc var value: String?
    @objc var cornerRadius: CGFloat = 5.0
    @objc var backgroundColor = UIColor.gtBlue
    @objc var font = UIFont.gtRegular(size: 15.0)
    @objc var width: CGFloat = 300.0
    @objc var height: CGFloat = 44.0
    @objc var xMargin = BaseTractElement.xMargin
    @objc var yMargin = BaseTractElement.yMargin
    
    override func getTextProperties() -> TractTextContentProperties {
        let textProperties = TractTextContentProperties()
        
        textProperties.font = .gtRegular(size: 18.0)
        textProperties.width = self.width
        textProperties.textAlign = .center
        
        return textProperties
    }
    
}
