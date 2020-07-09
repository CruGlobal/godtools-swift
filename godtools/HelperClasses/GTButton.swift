//
//  GTButton.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

// TODO: Remove this class. ~Levi
class GTButton: UIButton {
    
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
            return self.titleColor(for: UIControl.State.normal)!
        }
        set {
            self.setTitleColor(newValue, for: UIControl.State.normal)
        }
    }
    
    func designAsTractModalButton() {
        self.cornerRadius = 5.0
        self.color = .gtWhite
        self.tintColor = .gtWhite
        self.borderWidth = 1.0
        self.borderColor = .gtWhite
        self.backgroundColor = .clear
                
        self.layoutSubviews()
    }
}
