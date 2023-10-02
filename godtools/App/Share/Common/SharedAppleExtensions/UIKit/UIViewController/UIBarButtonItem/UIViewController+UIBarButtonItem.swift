//
//  UIViewController+UIBarButtonItem.swift
//  SharedAppleExtensions
//
//  Created by Levi Eggert on 5/20/20.
//  Copyright © 2020 Levi Eggert. All rights reserved.
//

import UIKit

public extension UIViewController {
  
    func addBarButtonItem(to barPosition: BarButtonItemBarPosition, index: Int? = nil, title: String?, style: UIBarButtonItem.Style?, color: UIColor?, target: Any?, action: Selector?) -> UIBarButtonItem {
        
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
    
    func addBarButtonItem(to barPosition: BarButtonItemBarPosition, index: Int? = nil, image: UIImage?, color: UIColor?, target: Any?, action: Selector?) -> UIBarButtonItem {
        
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
    
    func addBarButtonItem(item: UIBarButtonItem, barPosition: BarButtonItemBarPosition, index: Int? = nil) {
        switch barPosition {
        case .left:
            addLeftBarButtonItem(item: item, index: index)
        case .right:
            addRightBarButtonItem(item: item, index: index)
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
    
    func getLeftBarButtonItems() -> [UIBarButtonItem] {
        
        if let leadingItems = navigationItem.leftBarButtonItems, !leadingItems.isEmpty {
            return leadingItems
        }
        else if let leadingItem = navigationItem.leftBarButtonItem {
            return [leadingItem]
        }
        
        return Array()
    }
    
    func getRightBarButtonItems() -> [UIBarButtonItem] {
        
        if let trailingItems = navigationItem.rightBarButtonItems, !trailingItems.isEmpty {
            return trailingItems
        }
        else if let trailingItem = navigationItem.rightBarButtonItem {
            return [trailingItem]
        }
        
        return Array()
    }
}

// MARK: - Removing Button Items

public extension UIViewController {
    
    func removeAllBarButtonItems() {
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.leftBarButtonItems = Array()
        
        navigationItem.rightBarButtonItem = nil
        navigationItem.rightBarButtonItems = Array()
    }
    
    func removeBarButtonItem(item: UIBarButtonItem) {
        
        if var leadingItems = navigationItem.leftBarButtonItems, let index = leadingItems.firstIndex(of: item) {
            
            leadingItems.remove(at: index)
            navigationItem.leftBarButtonItems = leadingItems
        }
        else if navigationItem.leftBarButtonItem == item {
            
            navigationItem.leftBarButtonItem = nil
        }
        
        if var trailingItems = navigationItem.rightBarButtonItems, let index = trailingItems.firstIndex(of: item) {
            
            trailingItems.remove(at: index)
            navigationItem.rightBarButtonItems = trailingItems
        }
        else if navigationItem.rightBarButtonItem == item {
            
            navigationItem.rightBarButtonItem = nil
        }
    }
}
