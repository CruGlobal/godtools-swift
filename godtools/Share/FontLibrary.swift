//
//  FontLibrary.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

enum FontLibrary: String {
    
    case sfProDisplayLight = "SFProDisplay-Light"
    case sfProTextLight = "SFProText-Light"
    case sfProTextRegular = "SFProText-Regular"
    
    func font(size: CGFloat) -> UIFont? {
        if let font = UIFont(name: rawValue, size: size) {
            return font
        }
        print("WARNING: Failed to load font with name: \(rawValue)")
        print("Available font names:")
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print(" Family: \(family) Font names: \(names)")
        }
        
        return nil
    }
}
