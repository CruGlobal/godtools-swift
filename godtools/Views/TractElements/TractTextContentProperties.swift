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
        self.properties = ["i18nId", "value"]
    }
    
    // MARK: - XML Custom Properties
    
    override func customProperties() -> [String]? {
        return ["textAlign", "textScale"]
    }
    
    override func performCustomProperty(propertyName: String, value: String) {
        switch propertyName {
        case "textAlign":
            setupTextAlign(value)
        case "textScale":
            setupTextScale(value)
            
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
    
    private func setupTextScale(_ string: String) {
        let stringValue = string as NSString
        let floatValue = stringValue.floatValue
        self.textScale = CGFloat(floatValue)
    }
    
    func scaledFont() -> UIFont {
        return UIFont(name: font.fontName, size: font.pointSize * self.textScale) ?? font
    }
    
    // MARK: - View Properties
    
    var finalWidth: CGFloat {
        return self.width - (self.xMargin * 2)
    }
    var finalHeight: CGFloat {
        return self.height + (self.yMargin * 2)
    }
    
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    
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
                return UIFont.gtRegular(size: 18.0)
            } else {
                return _font!
            }
        }
        set {
            _font = newValue
        }
    }
    
    func getFrame() -> CGRect {
        return CGRect(x: self.xMargin,
                      y: self.yMargin,
                      width: self.finalWidth,
                      height: self.height + self.yMargin)
    }

}
