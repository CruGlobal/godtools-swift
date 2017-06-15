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
    
    private var _width: CGFloat?
    var width: CGFloat {
        get {
            if _width == nil {
                return 0.0
            } else {
                return _width! - (self.xMargin * 2)
            }
        }
        set {
            _width = newValue
        }
    }
    
    private var _height: CGFloat?
    var height: CGFloat {
        get {
            if _height == nil {
                return 0.0
            } else {
                return _height! + self.yMargin
            }
        }
        set {
            _height = newValue
        }
    }
    
    private var _xMargin: CGFloat?
    var xMargin: CGFloat {
        get {
            if _xMargin == nil {
                return BaseTractElement.xMargin
            } else {
                return _xMargin!
            }
        }
        set {
            _xMargin = newValue
        }
    }
    
    private var _yMargin: CGFloat?
    var yMargin: CGFloat {
        get {
            if _yMargin == nil {
                return BaseTractElement.yMargin
            } else {
                return _yMargin!
            }
        }
        set {
            _yMargin = newValue
        }
    }
    
    private var _font: UIFont?
    var font: UIFont {
        get {
            if _font == nil {
                return UIFont.gtRegular(size: 15.0)
            } else {
                return _font!
            }
        }
        set {
            _font = newValue
        }
    }

}
