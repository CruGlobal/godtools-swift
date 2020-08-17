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
    
    var rightItemsCount: Int {
        return navigationItem.rightBarButtonItems?.count ?? 0
    }
    
    func setNavBarLogo(image: UIImage?) {
        navigationItem.titleView = UIImageView(image: image)
    }
    
    func hideBackBarButtonItem() {
        navigationItem.leftBarButtonItems = nil
        navigationItem.setHidesBackButton(true, animated: false)
    }
        
    func addBarButtonItem(to barPosition: ButtonItemPosition, index: Int? = nil, title: String?, style: UIBarButtonItem.Style?, color: UIColor?, target: Any?, action: Selector?) -> UIBarButtonItem {
        
        let buttonStyle: UIBarButtonItem.Style = style ?? .plain
        
        let item = UIBarButtonItem(title: title, style: buttonStyle, target: target, action: action)
        if let color = color {
            item.tintColor = color
        }
        
        switch barPosition {
        case .left:
            addLeftBarButtonItem(item: item, index: index)
        case .right:
            addRightBarButtonItem(item: item, index: index)
        }
        
        return item
    }
    
    func addBarButtonItem(to barPosition: ButtonItemPosition, index: Int? = nil, image: UIImage?, color: UIColor?, target: Any?, action: Selector?) -> UIBarButtonItem {
        
        let item = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        if let color = color {
            item.tintColor = color
        }
        
        switch barPosition {
        case .left:
            addLeftBarButtonItem(item: item, index: index)
        case .right:
            addRightBarButtonItem(item: item, index: index)
        }
        
        return item
    }
    
    func addBarButtonItem(item: UIBarButtonItem, barPosition: ButtonItemPosition, index: Int? = nil) {
        switch barPosition {
        case .left:
            addLeftBarButtonItem(item: item, index: index)
        case .right:
            addRightBarButtonItem(item: item, index: index)
        }
    }
    
    func removeBarButtonItem(item: UIBarButtonItem, barPosition: ButtonItemPosition, index: Int? = nil) {
        switch barPosition {
        case .left:
            removeLeftBarButtonItem(item: item)
        case .right:
            removeRightBarButtonItem(item: item)
        }
    }
    
    private func addLeftBarButtonItem(item: UIBarButtonItem, index: Int?) {
        if var leftItems = navigationItem.leftBarButtonItems {
            if !leftItems.contains(item) {
                if let index = index, index >= 0 && index < leftItems.count {
                    leftItems.insert(item, at: index)
                }
                else {
                    leftItems.append(item)
                }
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
    
    private func addRightBarButtonItem(item: UIBarButtonItem, index: Int?) {
        if var rightItems = navigationItem.rightBarButtonItems {
            if !rightItems.contains(item) {
                if let index = index, index >= 0 && index < rightItems.count {
                    rightItems.insert(item, at: index)
                }
                else {
                    rightItems.append(item)
                }
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
