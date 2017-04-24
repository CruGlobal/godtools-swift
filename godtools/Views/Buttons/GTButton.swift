//
//  GTButton.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

@IBDesignable
class GTButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel?.text = self.titleLabel?.text?.localized
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var color: UIColor {
        get {
            return self.titleColor(for: UIControlState.normal)!
        }
        set {
            self.setTitleColor(newValue, for: UIControlState.normal)
        }
    }
}
