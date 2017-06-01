//
//  TractButtonProperties.swift
//  godtools
//
//  Created by Devserker on 5/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractButtonProperties: TractElementProperties {
    
    enum ButtonType {
        case url, event
    }
    
    var i18nId: String?
    var type: ButtonType = .url
    var value: String?
    var events: String?
    var width: CGFloat = 300.0
    var height: CGFloat = 44.0
    var xMargin = BaseTractElement.xMargin
    var yMargin = BaseTractElement.yMargin
    var cornerRadius: CGFloat = 5.0
    var backgroundColor = UIColor.gtBlue
    var color = UIColor.gtBlack
    var font = UIFont.gtRegular(size: 15.0)
    
    override func load(_ properties: [String: Any]) {
        super.load(properties)
        
        for property in properties.keys {
            switch property {
            case "value":
                self.value = properties[property] as! String?
            case "events":
                self.events = properties[property] as! String?
            case "i18n-id":
                self.i18nId = properties[property] as! String?
            case "type":
                self.setupType(properties[property] as! String)
            default: break
            }
        }
    }
    
    func setupType(_ type: String) {
        switch type {
        case "url":
            self.type = .url
        case "event":
            self.type = .event
        default: break
        }
    }
    
}
