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
                self.font = UIFont.gtLight(size: 28.0)
                self.textColor = UIColor.gtWhite
            case "blueTitle":
                self.font = UIFont.gtSemiBold(size: 28.0)
                self.textColor = UIColor.gtBlue
            case "blueHeader1":
                self.font = UIFont.gtSemiBold(size: 17.0)
                self.textColor = UIColor.gtBlue
            case "blackTitle":
                self.font = UIFont.gtLight(size: 28.0)
                self.textColor = UIColor.gtBlack
            case "blackText":
                self.font = UIFont.gtRegular(size: 15.0)
                self.textColor = UIColor.gtBlack
            case "blackTextSmall":
                self.font = UIFont.gtRegular(size: 13.0)
                self.textColor = UIColor.gtBlack
            case "blackTextLegend":
                self.font = UIFont.gtRegular(size: 10.0)
                self.textColor = UIColor.gtBlack
            case "redText":
                self.font = UIFont.gtRegular(size: 15.0)
                self.textColor = UIColor.gtRed
            case "greyHeader1":
                self.font = UIFont.gtRegular(size: 17.0)
                self.textColor = UIColor.gtGrey
            case "greyTextSmall":
                self.font = UIFont.gtRegular(size: 12.0)
                self.textColor = UIColor.gtGrey
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
