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
    
    case gtBlue
    case gtGrey
    case gtLightGrey
    case media
    case primaryNavBar
    case primaryTextColor
    case progressBarBlue
    case banner
    
    // This var uses custom SwiftUI color sets in the asset catalog
    var color: Color {
        switch self {
        case .gtBlue:           return Color("gtBlue")
        case .gtGrey:           return Color("gtGrey")
        case .gtLightGrey:      return Color("gtLightGrey")
        case .media:            return Color("media")
        case .primaryNavBar:    return Color("gtBlue")
        case .primaryTextColor: return Color("primaryTextColor")
        case .progressBarBlue:  return Color("progressBarBlue")
        case .banner:           return Color("banner")
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
            case .media:            return getMediaColor()
            case .primaryNavBar:    return getGtBlueColor()
            case .primaryTextColor: return getPrimaryTextColor()
            case .progressBarBlue:  return getProgressBarBlueColor()
            case .banner:           return getBannerColor()
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
        return UIColor(red: 128 / 255, green: 130 / 255, blue: 132 / 255, alpha: 1.0)
    }
    
    private func getMediaColor() -> UIColor {
        return UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1.0)
    }
    
    private func getPrimaryTextColor() -> UIColor {
        return UIColor(red: 90 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0)
    }
    
    private func getProgressBarBlueColor() -> UIColor {
        return UIColor(red: 54 / 255, green: 147 / 255, blue: 227 / 255, alpha: 1.0)
    }

    private func getBannerColor() -> UIColor {
        return UIColor(red: 219 / 255, green: 243 / 255, blue: 255 / 255, alpha: 1)
    }
}
