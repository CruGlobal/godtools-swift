//
//  UIViewController+UIBarButtonItem.swift
//  SharedAppleExtensions
//
//  Created by Levi Eggert on 5/20/20.
//  Copyright © 2020 Levi Eggert. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    func addBarButtonItem(barPosition: BarButtonItemBarPosition, index: Int?, title: String?, style: UIBarButtonItem.Style?, color: UIColor?, target: Any?, action: Selector?) -> UIBarButtonItem {
        
        let buttonStyle: UIBarButtonItem.Style = style ?? .plain
        
        let item = UIBarButtonItem(title: title, style: buttonStyle, target: target, action: action)
        if let color = color {
            item.tintColor = color
        }
        
        addBarButtonItem(item: item, barPosition: barPosition, index: index)
        
        return item
    }
    
    func addBarButtonItem(barPosition: BarButtonItemBarPosition, index: Int?, image: UIImage?, color: UIColor?, target: Any?, action: Selector?) -> UIBarButtonItem {
        
        let item = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        if let color = color {
            item.tintColor = color
        }
        
        addBarButtonItem(item: item, barPosition: barPosition, index: index)
        
        return item
    }
}

// MARK: - Retrieving Bar Items

extension UIViewController {
    
    func containsBarButtonItem(item: UIBarButtonItem) -> Bool {
        
        return getAllBarButtonItems().contains(item)
    }
    
    func getAllBarButtonItems() -> [UIBarButtonItem] {
        
        return getLeadingBarButtonItems() + getTrailingBarButtonItems()
    }
    
    func getLeadingBarButtonItems() -> [UIBarButtonItem] {
        
        if let leadingItems = navigationItem.leftBarButtonItems, !leadingItems.isEmpty {
            return leadingItems
        }
        else if let leadingItem = navigationItem.leftBarButtonItem {
            return [leadingItem]
        }
        
        return Array()
    }
    
    func getTrailingBarButtonItems() -> [UIBarButtonItem] {
        
        if let trailingItems = navigationItem.rightBarButtonItems, !trailingItems.isEmpty {
            return trailingItems
        }
        else if let trailingItem = navigationItem.rightBarButtonItem {
            return [trailingItem]
        }
        
        return Array()
    }
}

// MARK: - Adding Bar Items

extension UIViewController {
    
    func addBarButtonItem(item: UIBarButtonItem, barPosition: BarButtonItemBarPosition, index: Int?) {
        
        switch barPosition {
        
        case .leading:
            addLeadingBarButtonItem(item: item, index: index)
        
        
        case .trailing:
            addTrailingBarButtonItem(item: item, index: index)
        }
    }
    
    func addLeadingBarButtonItem(item: UIBarButtonItem, index: Int?) {
        
        if var leadingItems = navigationItem.leftBarButtonItems, !leadingItems.isEmpty {
            
            if !leadingItems.contains(item) {
                
                if let index = index, index >= 0 && index < leadingItems.count {
                    
                    leadingItems.insert(item, at: index)
                }
                else {
                    
                    leadingItems.append(item)
                }
                
                navigationItem.leftBarButtonItems = leadingItems
            }
        }
        else {
            
            navigationItem.leftBarButtonItem = item
        }
    }

    func addTrailingBarButtonItem(item: UIBarButtonItem, index: Int?) {
        
        if var trailingItems = navigationItem.rightBarButtonItems, !trailingItems.isEmpty {
            
            if !trailingItems.contains(item) {
                
                if let index = index, index >= 0 && index < trailingItems.count {
                    
                    trailingItems.insert(item, at: index)
                }
                else {
                    
                    trailingItems.append(item)
                }
                
                navigationItem.rightBarButtonItems = trailingItems
            }
        }
        else {
            
            navigationItem.rightBarButtonItem = item
        }
    }
}

// MARK: - Removing Bar Items

extension UIViewController {
    
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
