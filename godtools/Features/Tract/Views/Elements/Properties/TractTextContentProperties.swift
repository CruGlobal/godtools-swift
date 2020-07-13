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
    
    @objc var i18nId: String = ""
    @objc var textAlign: NSTextAlignment = .left
    @objc var localTextColor: UIColor?
    @objc var textScale: CGFloat = 1.0
    @objc var bold: Bool = false
    @objc var italic: Bool = false
    @objc var underline: Bool = false
    @objc var value: String = ""
    
    override func defineProperties() {
        self.properties = ["i18nId", "value"]
    }
    
    // MARK: - XML Custom Properties
    
    override func customProperties() -> [String]? {
        return ["textAlign", "textScale", "textColor", "textStyle"]
    }
    
    override func performCustomProperty(propertyName: String, value: String) {
        switch propertyName {
        case "textAlign":
            setupTextAlign(value)
        case "textScale":
            setupTextScale(value)
        case "textColor":
            self.localTextColor = value.getRGBAColor()
        case "textStyle":
            setupTextStyle(value)
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
    
    private func setupTextStyle(_ string: String) {
        if string.range(of:"bold") != nil {
            self.bold = true
        }
        
        if string.range(of:"italic") != nil {
            self.italic = true
        }
        
        if string.range(of:"underline") != nil {
            self.underline = true
        }
    }
    
    func scaledFont(language: LanguageModel) -> UIFont {
        return self.font.transformToAppropriateFontByLanguage(language, textScale: self.textScale)
    }
    
    func colorFor(_ element: BaseTractElement, pageProperties: TractPageProperties) -> UIColor {
        if localTextColor != nil {
            return localTextColor!
        }
        
        if BaseTractElement.isElement(element, kindOf: TractCard.self) {
            if BaseTractElement.isElement(element, kindOf: TractLabel.self) {
                return primaryColor
            }
            if pageProperties.cardTextColor != nil {
                return pageProperties.cardTextColor!
            }
        }
        
        if BaseTractElement.isElement(element, kindOf: TractHeading.self) {
            return primaryColor
        }
        
        if BaseTractElement.isElement(element, kindOf: TractHeader.self) {
            return primaryTextColor
        }
        
        return textColor
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
                return TractTextContent.xTextMargin
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
                return TractTextContent.yTextMargin
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
                return UIFont.gtRegular(size: 16.0)
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
