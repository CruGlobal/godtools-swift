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
    
    var i18nId: String?
    var value: String?
    var events: String?
    var cornerRadius: CGFloat = 5.0
    var backgroundColor = UIColor.gtBlue
    var color = UIColor.gtBlack
    var font = UIFont.gtRegular(size: 15.0)
    var type: ButtonType = .url
    
    // MARK: - View Properties
    
    var width: CGFloat = 300.0
    var height: CGFloat = 44.0
    var xMargin = BaseTractElement.xMargin
    var yMargin = BaseTractElement.yMargin
    
    // MARK: - Setup of custom properties
    
    override func customProperties() -> [String]? {
        return ["type"]
    }
    
    override func performCustomProperty(propertyName: String, value: String) {
        switch propertyName {
        case "type":
            setupType(value)
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
    
}
