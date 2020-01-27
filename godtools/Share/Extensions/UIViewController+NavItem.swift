//
//  UIViewController+NavItem.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

enum ButtonItemPosition {
    case left
    case right
}

extension UIViewController {
    
    func setNavBarLogo(image: UIImage?) {
        navigationItem.titleView = UIImageView(image: image)
    }
    
    func hideBackBarButtonItem() {
        navigationItem.leftBarButtonItems = nil
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    func addSkipButtonItem(target: Any?, action: Selector?) -> UIBarButtonItem {
        return addBarButtonItem(
            to: .right,
            title: NSLocalizedString("navigationBar.navigationItem.skip", comment: ""),
            color: UIColor(red: 0.231, green: 0.643, blue: 0.859, alpha: 1),
            target: target,
            action: action
        )
    }
        
    func addBarButtonItem(to barPosition: ButtonItemPosition, title: String?, color: UIColor?, target: Any?, action: Selector?) -> UIBarButtonItem {
        
        let item = UIBarButtonItem(title: title, style: .plain, target: target, action: action)
        if let color = color {
            item.tintColor = color
        }
        
        switch barPosition {
        case .left:
            addLeft(barButtonItem: item)
        case .right:
            addRight(barButtonItem: item)
        }
        
        return item
    }
    
    func addBarButtonItem(to barPosition: ButtonItemPosition, image: UIImage?, color: UIColor?, target: Any?, action: Selector?) -> UIBarButtonItem {
        
        let item = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        if let color = color {
            item.tintColor = color
        }
        
        switch barPosition {
        case .left:
            addLeft(barButtonItem: item)
        case .right:
            addRight(barButtonItem: item)
        }
        
        return item
    }
    
    private func addLeft(barButtonItem: UIBarButtonItem) {
        if var leftItems = navigationItem.leftBarButtonItems {
            leftItems.append(barButtonItem)
            navigationItem.leftBarButtonItems = leftItems
        }
        else {
            navigationItem.leftBarButtonItem = barButtonItem
        }
    }
    
    private func addRight(barButtonItem: UIBarButtonItem) {
        if var rightItems = navigationItem.rightBarButtonItems {
            rightItems.append(barButtonItem)
            navigationItem.rightBarButtonItems = rightItems
        }
        else {
            navigationItem.rightBarButtonItem = barButtonItem
        }
    }
}
