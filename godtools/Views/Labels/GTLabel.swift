//
//  GTLabel.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

@IBDesignable
class GTLabel: UILabel {
    
    @IBInspectable var gtStyle: String = "" {
        didSet {
            switch self.gtStyle {
            case "whiteTitle":
                self.font = .gtLight(size: 28.0)
                self.textColor = .gtWhite
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
            case "blackTextSmall":
                self.font = .gtRegular(size: 13.0)
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
        }
    }
    
    @IBInspectable var translationKey: String = "" {
        didSet {
            self.text = translationKey.localized
        }
    }
    
}
