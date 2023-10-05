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
    let target: AnyObject
    let action: Selector
    
    init(contentType: NavBarItemContentType, style: UIBarButtonItem.Style?, color: UIColor?, target: AnyObject, action: Selector) {
        
        self.contentType = contentType
        self.style = style ?? .plain
        self.color = color
        self.target = target
        self.action = action
    }
    
    func getNewBarButtonItem() -> UIBarButtonItem {
        
        return getNewBarButtonItem(contentType: contentType)
    }
    
    func getNewBarButtonItem(contentType: NavBarItemContentType) -> UIBarButtonItem {
        
        let buttonItem: UIBarButtonItem
        
        switch contentType {
        
        case .image(let value):
            buttonItem = UIBarButtonItem(image: value, style: style, target: target, action: action)
        
        case .title(let value):
            buttonItem = UIBarButtonItem(title: value, style: style, target: target, action: action)
        }
        
        if let color = color {
            buttonItem.tintColor = color
        }
        
        return buttonItem
    }
}
