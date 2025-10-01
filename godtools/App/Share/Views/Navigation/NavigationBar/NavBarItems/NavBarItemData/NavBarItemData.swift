//
//  NavBarItemData.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

class NavBarItemData {
    
    let contentType: NavBarItemContentType
    let style: UIBarButtonItem.Style
    let color: UIColor?
    let target: AnyObject?
    let action: Selector?
    let accessibilityIdentifier: String?
    
    init(contentType: NavBarItemContentType, color: UIColor?, target: AnyObject?, action: Selector?, accessibilityIdentifier: String?, style: UIBarButtonItem.Style = .plain) {
        
        self.contentType = contentType
        self.style = style // NOTE: I noticed in iOS 26 when Style is (done) the UIBarButtonItem tintColor is not applied. ~Levi
        self.color = color
        self.target = target
        self.action = action
        self.accessibilityIdentifier = accessibilityIdentifier
    }
    
    func getNewBarButtonItem(navBarAppearance: AppNavigationBarAppearance?) -> UIBarButtonItem {
        
        return getNewBarButtonItem(
            contentType: contentType,
            navBarAppearance: navBarAppearance
        )
    }
    
    func getNewBarButtonItem(contentType: NavBarItemContentType, navBarAppearance: AppNavigationBarAppearance?) -> UIBarButtonItem {
        
        let buttonItem: UIBarButtonItem
        
        switch contentType {
        
        case .custom(let view):
            buttonItem = UIBarButtonItem(customView: view)
            
        case .image(let value):
            buttonItem = UIBarButtonItem(image: value, style: style, target: target, action: action)
        
        case .title(let value):
            buttonItem = UIBarButtonItem(title: value, style: style, target: target, action: action)
        }
        
        if let color = self.color {
            buttonItem.tintColor = color
        }
        else if let navBarControlColor = navBarAppearance?.controlColor {
            buttonItem.tintColor = navBarControlColor
        }
        
        if let accessibilityIdentifier = self.accessibilityIdentifier {
            buttonItem.accessibilityIdentifier = accessibilityIdentifier
        }
        
        if #available(iOS 26, *) {
            // This disables the liquid glass effect on UINavigation Button Items. ~Levi
            buttonItem.hidesSharedBackground = true
            buttonItem.sharesBackground = false
        }
        
        return buttonItem
    }
}
