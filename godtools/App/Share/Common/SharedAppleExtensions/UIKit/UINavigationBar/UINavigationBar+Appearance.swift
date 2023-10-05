//
//  UINavigationBar+Appearance.swift
//  SharedAppleExtensions
//
//  Created by Levi Eggert on 10/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

@available(*, deprecated) // TODO: Needs to be removed in GT-2154.  All navigation bar button item logic needs to be in Share/Views/Navigation/NavigationBar/* ~Levi
public extension UINavigationBar {
    
    func setupNavigationBarAppearance(backgroundColor: UIColor, controlColor: UIColor?, titleFont: UIFont?, titleColor: UIColor?, isTranslucent: Bool) {
        
        internalSetupNavigationBarAppearance(
            backgroundColor: backgroundColor,
            controlColor: controlColor,
            titleTextAttributes: getTitleTextAttributes(titleFont: titleFont, titleColor: titleColor),
            isTranslucent: isTranslucent
        )
    }
    
    private func getTitleTextAttributes(titleFont: UIFont?, titleColor: UIColor?) -> [NSAttributedString.Key: Any] {
        
        var titleTextAttributes: [NSAttributedString.Key: Any] = Dictionary()
        
        if let titleFont = titleFont {
            titleTextAttributes[NSAttributedString.Key.font] = titleFont
        }
        
        if let titleColor = titleColor {
            titleTextAttributes[NSAttributedString.Key.foregroundColor] = titleColor
        }
        
        return titleTextAttributes
    }
    
    private func internalSetupNavigationBarAppearance(backgroundColor: UIColor, controlColor: UIColor?, titleTextAttributes: [NSAttributedString.Key: Any]?, isTranslucent: Bool) {
    
        self.isTranslucent = isTranslucent
        
        if let controlColor = controlColor {
            tintColor = controlColor
        }
                
        if let titleTextAttributes = titleTextAttributes, !titleTextAttributes.isEmpty {
            self.titleTextAttributes = titleTextAttributes
        }
        
        if #available(iOS 13, *) {
            
            let appearance = UINavigationBarAppearance()
                        
            if isTranslucent {
                
                appearance.configureWithTransparentBackground()
                appearance.backgroundImage = UIImage.createImageWithColor(color: backgroundColor)
                appearance.backgroundColor = .clear
            }
            else {
                
                appearance.configureWithOpaqueBackground()
                appearance.backgroundImage = nil
                appearance.backgroundColor = backgroundColor
            }
            
            appearance.shadowColor = .clear
            
            if let titleTextAttributes = titleTextAttributes, !titleTextAttributes.isEmpty {
                appearance.titleTextAttributes = titleTextAttributes
            }
            
            standardAppearance = appearance
            scrollEdgeAppearance = appearance
        }
        else {
            
            if isTranslucent {
                
                barTintColor = .clear
                
                let backgroundImage: UIImage? = backgroundColor == .clear ? UIImage() : UIImage.createImageWithColor(color: backgroundColor)
                
                setBackgroundImage(backgroundImage, for: .default)
            }
            else {
               
                barTintColor = backgroundColor
                setBackgroundImage(nil, for: .default)
            }
            
            shadowImage = UIImage()
        }
    }
}
