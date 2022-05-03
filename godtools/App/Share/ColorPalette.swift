//
//  ColorPalette.swift
//  godtools
//
//  Created by Levi Eggert on 12/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

enum ColorPalette {
    
    static let bannerColor: UIColor = UIColor(red: 219 / 255, green: 243 / 255, blue: 255 / 255, alpha: 1)
    
    case gtBlue
    case gtGrey
    case gtLightGrey
    case primaryNavBar
    
    // This var uses custom SwiftUI color sets in the asset catalog
    var color: Color {
        switch self {
        case .gtBlue:           return Color("gtBlue")
        case .gtGrey:           return Color("gtGrey")
        case .gtLightGrey:      return Color("gtLightGrey")
        case .primaryNavBar:    return Color("gtBlue")
        }
    }
    
    var uiColor: UIColor {
        // This initializer that creates a `UIColor` from SwiftUI's `Color` is only available in iOS 14, so for now we'll have duplicate definitions for each color-- one for SwiftUI in the Asset Catalog, and the second one here for UIColor.
        // TODO: - GT-1533: Once we bump the minimum deployment target to iOS 14, we can remove all the UIColor logic here and define colors in the Asset Catalog only.
        if #available(iOS 14.0, *) {
            return UIColor(color)
            
        } else {
            switch self {
            case .gtBlue:           return getGtBlueColor()
            case .gtGrey:           return getGtBlueColor()
            case .gtLightGrey:      return getGtLightGreyColor()
            case .primaryNavBar:    return getGtBlueColor()
            }
        }
    }
    
    private func getGtBlueColor() -> UIColor {
        return UIColor(red: 59 / 255, green: 164 / 255, blue: 219 / 255, alpha: 1.0)
    }
    
    private func getGtGreyColor() -> UIColor {
        return UIColor(red: 90 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0)
    }
    
    private func getGtLightGreyColor() -> UIColor {
        return UIColor(red: 128 / 255.0, green: 130 / 255, blue: 132 / 255, alpha: 1.0)
    }
}
