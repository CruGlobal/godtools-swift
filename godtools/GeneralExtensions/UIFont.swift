//
//  UIFont.swift
//  godtools
//
//  Created by Pablo Marti on 7/18/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

extension UIFont {
    
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
    
    static func defaultFont(size: CGFloat, weight: CGFloat?) -> UIFont {
        
        if let weight = weight {
            return UIFont.systemFont(ofSize: size, weight: UIFont.Weight(rawValue: weight))
        }
    
        return UIFont.systemFont(ofSize: size)
    }
    
    static func gtRegular(size: CGFloat) -> UIFont {
        return UIFont.buildGTFont(size: size, weight: UIFont.Weight.regular.rawValue)
    }
    
    static func gtLight(size: CGFloat) -> UIFont {
        return UIFont.buildGTFont(size: size, weight: UIFont.Weight.light.rawValue)
    }
    
    static func gtThin(size: CGFloat) -> UIFont {
        return UIFont.buildGTFont(size: size, weight: UIFont.Weight.thin.rawValue)
    }
    
    static func gtSemiBold(size: CGFloat) -> UIFont {
        return UIFont.buildGTFont(size: size, weight: UIFont.Weight.semibold.rawValue)
    }
    
    static func buildGTFont(size: CGFloat, weight: CGFloat) -> UIFont {
        if shouldTransformLanguage() {
            return UIFont.buildCustomGTFontWithSize(size, weight: weight)
        } else {
            return UIFont.defaultFont(size: size, weight: weight)
        }
    }
    
    static func buildCustomGTFontWithSize(_ size: CGFloat, weight: CGFloat) -> UIFont {
        
        let language = LanguagesManager.defaultLanguage
        var customFont: UIFont?
        
        if language?.code == "am" {
            if (weight == UIFont.Weight.semibold.rawValue) || (weight == UIFont.Weight.bold.rawValue) {
                customFont = FontLibrary.notoSansEthiopicBold.font(size: size)
            } else {
                customFont = FontLibrary.notoSansEthiopic.font(size: size)
            }
        }
        
        return customFont ?? UIFont.defaultFont(size: size, weight: weight)
    }
    
    static func shouldTransformLanguage() -> Bool {
        guard let language = LanguagesManager.defaultLanguage else {
            return false
        }
        
        if language.code == "am" {
            return true
        } else {
            return false
        }
    }
    
    func transformToAppropriateFontByLanguage(_ language: LanguageModel, textScale: CGFloat = 1.0) -> UIFont {
        
        let fontSize = pointSize * textScale
        var customFont: UIFont?
        
        if language.code == "am" {
            if self.fontName.lowercased().contains("bold") {
                customFont = FontLibrary.notoSansEthiopicBold.font(size: fontSize)
            } else {
                customFont = FontLibrary.notoSansEthiopic.font(size: fontSize)
            }
        }
        if language.code == "my" {
            if self.fontName.lowercased().contains("bold") {
                customFont = FontLibrary.notoSansMyanmarBold.font(size: fontSize)
            } else {
                customFont = FontLibrary.notoSansMyanmar.font(size: fontSize)
            }
        }
        
        return customFont ?? UIFont.defaultFont(size: fontSize, weight: nil)
    }
    
    
    func setBold() -> UIFont {
        if isBold {
            return self
        }
        
        guard let fontDescriptorVar: UIFontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold) else {
            return self
        }
        
        return UIFont(descriptor: fontDescriptorVar, size: 0)
    }
    
    func setItalic()-> UIFont {
        if(isItalic) {
            return self
        }
        
        guard let fontDescriptorVar: UIFontDescriptor = fontDescriptor.withSymbolicTraits(.traitItalic) else {
            return self
        }
        
        return UIFont(descriptor: fontDescriptorVar, size: 0)
    }
    
    func setBoldItalic()-> UIFont {
        let fontDescriptorVar = fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(arrayLiteral: .traitBold, .traitItalic))
        return UIFont(descriptor: fontDescriptorVar!, size: 0)
    }
}
