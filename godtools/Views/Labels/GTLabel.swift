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
            case "blueHeader1":
                self.font = UIFont.gtSemiBold(size: 17.0)
                self.textColor = UIColor.gtBlue
            case "blackText":
                self.font = UIFont.gtRegular(size: 15.0)
                self.textColor = UIColor.gtBlack
            case "redText":
                self.font = UIFont.gtRegular(size: 15.0)
                self.textColor = UIColor.gtRed
            default:
                break
            }
        }
    }
    
}
