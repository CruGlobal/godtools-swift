//
//  UIFont.swift
//  godtools
//
//  Created by Pablo Marti on 7/18/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

extension UIFont {
    
    static func gtRegular(size: CGFloat) -> UIFont {
        return UIFont.buildGTFont(size: size, weight: UIFontWeightRegular)
    }
    
    static func gtLight(size: CGFloat) -> UIFont {
        return UIFont.buildGTFont(size: size, weight: UIFontWeightLight)
    }
    
    static func gtThin(size: CGFloat) -> UIFont {
        return UIFont.buildGTFont(size: size, weight: UIFontWeightThin)
    }
    
    static func gtSemiBold(size: CGFloat) -> UIFont {
        return UIFont.buildGTFont(size: size, weight: UIFontWeightSemibold)
    }
    
    static func buildGTFont(size: CGFloat, weight: CGFloat) -> UIFont {
        if shouldTransformLanguage() {
            return UIFont.buildCustomGTFontWithSize(size, weight: weight)
        } else {
            return UIFont.systemFont(ofSize: size, weight: weight)
        }
    }
    
    static func buildCustomGTFontWithSize(_ size: CGFloat, weight: CGFloat) -> UIFont {
        let language = LanguagesManager.defaultLanguage
        
        if language?.code == "am" {
            if weight == UIFontWeightSemibold || weight == UIFontWeightBold {
                return UIFont(name: "NotoSansEthiopic-Bold", size: size)!
            } else {
                return UIFont(name: "NotoSansEthiopic", size: size)!
            }
        }
        
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
    
    static func shouldTransformLanguage() -> Bool {
        guard let language = LanguagesManager.defaultLanguage else {
            return false
        }
        
        if language.code == "am-ET" {
            return true
        } else {
            return false
        }
    }
    
    func transformToAppropriateFontByLanguage(_ language: Language, textScale: CGFloat = 1.0) -> UIFont {
        var fontSize = self.pointSize
        var fontName = self.fontName
        
        if language.code == "am-ET" {
            if self.fontName.lowercased().contains("bold") {
                fontName = "NotoSansEthiopic-Bold"
            } else {
                fontName = "NotoSansEthiopic"
            }
        }
        
        fontSize = fontSize * textScale
        
        return UIFont(name: fontName, size: fontSize)!
    }
    
}
