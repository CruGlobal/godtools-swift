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
        
    func addBarButtonItem(to barPosition: ButtonItemPosition, title: String?, color: UIColor?, target: Any?, action: Selector?) -> UIBarButtonItem {
        
        let item = UIBarButtonItem(title: title, style: .plain, target: target, action: action)
        if let color = color {
            item.tintColor = color
        }
        
        switch barPosition {
        case .left:
            addLeftBarButtonItem(item: item)
        case .right:
            addRightBarButtonItem(item: item)
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
            addLeftBarButtonItem(item: item)
        case .right:
            addRightBarButtonItem(item: item)
        }
        
        return item
    }
    
    func addBarButtonItem(item: UIBarButtonItem, barPosition: ButtonItemPosition) {
        switch barPosition {
        case .left:
            addLeftBarButtonItem(item: item)
        case .right:
            addRightBarButtonItem(item: item)
        }
    }
    
    func removeBarButtonItem(item: UIBarButtonItem, barPosition: ButtonItemPosition) {
        switch barPosition {
        case .left:
            removeLeftBarButtonItem(item: item)
        case .right:
            removeRightBarButtonItem(item: item)
        }
    }
    
    private func addLeftBarButtonItem(item: UIBarButtonItem) {
        if var leftItems = navigationItem.leftBarButtonItems {
            if !leftItems.contains(item) {
                leftItems.append(item)
                navigationItem.leftBarButtonItems = leftItems
            }
        }
        else {
            navigationItem.leftBarButtonItem = item
        }
    }
    
    private func removeLeftBarButtonItem(item: UIBarButtonItem) {
        if var leftItems = navigationItem.leftBarButtonItems {
            if leftItems.contains(item) {
                if let index = leftItems.firstIndex(of: item) {
                    leftItems.remove(at: index)
                    navigationItem.leftBarButtonItems = leftItems
                }
            }
        }
        else {
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    private func addRightBarButtonItem(item: UIBarButtonItem) {
        if var rightItems = navigationItem.rightBarButtonItems {
            if !rightItems.contains(item) {
                rightItems.append(item)
                navigationItem.rightBarButtonItems = rightItems
            }
        }
        else {
            navigationItem.rightBarButtonItem = item
        }
    }
    
    private func removeRightBarButtonItem(item: UIBarButtonItem) {
        if var rightItems = navigationItem.rightBarButtonItems {
            if rightItems.contains(item) {
                if let index = rightItems.firstIndex(of: item) {
                    rightItems.remove(at: index)
                    navigationItem.rightBarButtonItems = rightItems
                }
            }
        }
        else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}
