//
//  GTAttributtedLabel.swift
//  godtools
//
//  Created by Igor Ostriz on 18/01/2019.
//  Copyright © 2019 Cru. All rights reserved.
//


import UIKit
import TTTAttributedLabel


class GTAttributedLabel: TTTAttributedLabel {

    @IBInspectable var gtStyle: String = "" {
        didSet {
            switch self.gtStyle {
            case "toolFrontTitle":
                self.font = .gtThin(size: 54.0)
                self.textColor = .gtBlack
            case "toolFrontSubTitle":
                self.font = .gtRegular(size: 18.0)
                self.textColor = .gtBlack
            case "pageHeaderNumber":
                self.font = .gtThin(size: 54.0)
                self.textColor = .gtWhite
            case "pageHeaderTitle":
                self.font = .gtThin(size: 18.0)
                self.textColor = .gtWhite
            case "tabTitle":
                self.font = .gtSemiBold(size: 18.0)
                self.textColor = .gtBlack
            case "whiteTitle":
                self.font = .gtLight(size: 28.0)
                self.textColor = .gtWhite
            case "whiteSubTitle":
                self.font = .gtRegular(size: 22.0)
                self.textColor = .gtWhite
            case "blueSubTitle":
                self.font = .gtRegular(size: 34.0)
                self.textColor = .gtBlue
            case "blueTitle":
                self.font = .gtSemiBold(size: 28.0)
                self.textColor = .gtBlue
            case "blueHeader1":
                self.font = .gtSemiBold(size: 17.0)
                self.textColor = .gtBlue
            case "blackTitle":
                self.font = .gtLight(size: 28.0)
                self.textColor = .gtBlack
            case "blackText":
                self.font = .gtRegular(size: 15.0)
                self.textColor = .gtBlack
            case "blackTextSemiBold":
                self.font = .gtSemiBold(size: 15.0)
                self.textColor = .gtBlack
            case "blackTextSmall":
                self.font = .gtRegular(size: 13.0)
                self.textColor = .gtBlack
            case "blackTextSmaller":
                self.font = .gtRegular(size: 12.0)
                self.textColor = .gtBlack
            case "blackTextLegend":
                self.font = .gtRegular(size: 10.0)
                self.textColor = .gtBlack
            case "redText":
                self.font = .gtRegular(size: 15.0)
                self.textColor = .gtRed
            case "greyHeader1":
                self.font = .gtRegular(size: 17.0)
                self.textColor = .gtGrey
            case "greyTextSmall":
                self.font = .gtRegular(size: 12.0)
                self.textColor = .gtGrey
            default:
                break
            }
            
            self.linkAttributes = [kCTFontNameAttribute: self.font.fontName, kCTFontSizeAttribute: self.font.pointSize, kCTForegroundColorAttributeName: UIColor.blue]
            self.activeLinkAttributes = [kCTForegroundColorAttributeName: UIColor.gray]
        }
    }
    
    @IBInspectable var translationKey: String = "" {
        didSet {
            self.text = translationKey.localized
        }
    }
    
}
