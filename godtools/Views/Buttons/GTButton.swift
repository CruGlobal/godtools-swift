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
    
    @IBInspectable var translationKey: String = "" {
        didSet {
            self.setTitle(translationKey.localized, for: .normal)
        }
    }
    
    func designAsDownloadButton() {
        self.designAsToolDetailButton()
        
        self.color = .gtWhite
        self.tintColor = .gtWhite
        self.borderWidth = 0.0
        self.borderColor = .clear
        self.backgroundColor = .gtGreen
        self.setImage(#imageLiteral(resourceName: "download_white"), for: .normal)
        self.translationKey = "download"
        
        self.layoutSubviews()
    }
    
    func designAsDeleteButton() {
        self.designAsToolDetailButton()
        
        self.color = .gtRed
        self.tintColor = .gtRed
        self.borderWidth = 1.0
        self.borderColor = .gtRed
        self.backgroundColor = .gtWhite
        self.setImage(#imageLiteral(resourceName: "delete_red"), for: .normal)
        self.translationKey = "remove"
        
        self.layoutSubviews()
    }
    
    fileprivate func designAsToolDetailButton() {
        self.cornerRadius = 5.0
        self.titleLabel?.font = UIFont.gtRegular(size: 15.0)
        self.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 10.0)
        self.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)
        
        self.increaseTitleWidth()
    }
    
    fileprivate func increaseTitleWidth() {
        var labelFrame = self.titleLabel?.frame
        labelFrame?.size.width = (labelFrame?.size.width)! + 30
        self.titleLabel?.frame = labelFrame!
    }

}
