//
//  FontLibrary.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SwiftUI

enum FontLibrary: String {
    
    case sfProDisplayLight = "SFProDisplay-Light"
    case sfProDisplayRegular = "SFProDisplay-Regular"
    case sfProTextBold = "SFProText-Bold"
    case sfProTextLight = "SFProText-Light"
    case sfProTextRegular = "SFProText-Regular"
    case sfProTextSemibold = "SFProText-Semibold"
    
    func uiFont(size: CGFloat) -> UIFont? {
        
        if let font = UIFont(name: rawValue, size: size) {
            return font
        }
        
        print("WARNING: Failed to load font with name: \(rawValue)")
        
        FontLibrary.logAvailableFonts()
        
        return nil
    }
    
    func font(size: CGFloat) -> Font {
        return Font.custom(rawValue, size: size)
    }
    
    static func systemUIFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
    
    static func logAvailableFonts() {
        print("Available font names:")
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print(" Family: \(family) Font names: \(names)")
        }
    }
}
