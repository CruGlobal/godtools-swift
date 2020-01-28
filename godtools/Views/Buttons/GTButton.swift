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
            return self.titleColor(for: UIControl.State.normal)!
        }
        set {
            self.setTitleColor(newValue, for: UIControl.State.normal)
        }
    }
    
    @IBInspectable var translationKey: String = "" {
        didSet {
            let state = self.isEnabled ? UIControl.State.normal : UIControl.State.disabled
            
            let primaryLanguage = LanguagesManager().loadPrimaryLanguageFromDisk()?.code
            let localizedTitle = translationKey.localized(for: primaryLanguage) ?? translationKey.localized
            self.setTitle(localizedTitle, for: state)
        }
    }
    
    func designAsUnavailableButton() {
        self.designAsToolDetailButton()
        
        self.color = .gtWhite
        self.tintColor = .gtWhite
        self.borderWidth = 0.0
        self.borderColor = .clear
        self.backgroundColor = .gtGrey
        self.setImage(#imageLiteral(resourceName: "download_white"), for: .normal)
        self.translationKey = "unavailable"
        
        self.isEnabled = false
        
        self.layoutSubviews()
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
    
    func designAsOpenToolButton() {
        
        backgroundColor = UIColor(red: 0.231, green: 0.643, blue: 0.859, alpha: 1)
        layer.cornerRadius = 6
        titleLabel?.font = UIFont.gtRegular(size: 15.0)
        setTitleColor(.white, for: .normal)
        translationKey = "openTool"
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
    
    func designAsTractModalButton() {
        self.cornerRadius = 5.0
        self.color = .gtWhite
        self.tintColor = .gtWhite
        self.borderWidth = 1.0
        self.borderColor = .gtWhite
        self.backgroundColor = .clear
                
        self.layoutSubviews()
    }
    
    fileprivate func designAsToolDetailButton() {
        self.cornerRadius = 5.0
        self.titleLabel?.font = UIFont.gtRegular(size: 15.0)
        
        if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight {
            self.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 10.0)
            self.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 0.0)
        }
        else {
            self.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 0.0)
            self.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 10.0)
        }
        
        self.isEnabled = true
        
        self.increaseTitleWidth()
    }
    
    fileprivate func increaseTitleWidth() {
        var labelFrame = self.titleLabel?.frame
        
        // Warning: Overlapping accesses to 'labelFrame', but modification requires exclusive access; consider copying to a local variable
//        labelFrame?.size.width = (labelFrame?.size.width)! + 30
        labelFrame?.size.width += 30
        self.titleLabel?.frame = labelFrame!
    }

}
