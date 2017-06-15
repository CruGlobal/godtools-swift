//
//  TractTextContentProperties.swift
//  godtools
//
//  Created by Devserker on 5/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractTextContentProperties: TractProperties {
    
    // MARK: - XML Properties
    
    var i18nId: String = ""
    var textAlign: NSTextAlignment = .left
    // textColor
    var textScale: CGFloat = 1.0
    var value: String = ""
    
    override func defineProperties() {
        self.properties = ["i18nId", "textScale", "value"]
    }
    
    // MARK: - XML Custom Properties
    
    override func customProperties() -> [String]? {
        return ["textAlign"]
    }
    
    override func performCustomProperty(propertyName: String, value: String) {
        switch propertyName {
        case "textAlign":
            setupTextAlign(value)
        default: break
        }
    }
    
    private func setupTextAlign(_ string: String) {
        switch string {
        case "start":
            self.textAlign = .left
        case "end":
            self.textAlign = .right
        case "center":
            self.textAlign = .center
        default:
            self.textAlign = .left
        }
    }
    
    // MARK: - View Properties
    
    private var _width: CGFloat = 0.0
    var width: CGFloat {
        get {
            return _width - (self.xMargin * 2)
        }
        set {
            _width = newValue
        }
    }
    var height: CGFloat = 0.0
    var xMargin: CGFloat = BaseTractElement.xMargin
    var yMargin: CGFloat = BaseTractElement.yMargin
    var font = UIFont.gtRegular(size: 15.0)

}
