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
        return UIFont.systemFont(ofSize: size, weight: UIFontWeightRegular).transformToAppropriateFont()
    }
    
    static func gtLight(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFontWeightLight).transformToAppropriateFont()
    }
    
    static func gtThin(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFontWeightThin).transformToAppropriateFont()
    }
    
    static func gtSemiBold(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFontWeightSemibold).transformToAppropriateFont()
    }
    
    func transformToAppropriateFont() -> UIFont {
        if GTSettings.shared.primaryLanguageId == nil {
            return self
        }
        
        let languagesManager = LanguagesManager()
        let language = languagesManager.loadPrimaryLanguageFromDisk()
        
        return transformToAppropriateFontByLanguage(language!, textScale: 1.0)
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
