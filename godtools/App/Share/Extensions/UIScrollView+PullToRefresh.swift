//
//  UIScrollView+PullToRefresh.swift
//  godtools
//
//  Created by Rachael Skeath on 4/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

// This extension allows us to use UIKit RefreshControl in SwiftUI.
// TODO: - In iOS 15, there's a simple `.refreshable {}` modifier we can use on the SwiftUI List instead and delete all this.
extension UIScrollView {
    private enum Keys {
        static var onValueChanged: UInt8 = 0
    }
    
    typealias ValueChangedAction = ((_ refreshControl: UIRefreshControl) -> Void)
    
    private var onValueChanged: ValueChangedAction? {
        get {
            objc_getAssociatedObject(self, &Keys.onValueChanged) as? ValueChangedAction
        }
        set {
            objc_setAssociatedObject(self, &Keys.onValueChanged, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func onRefresh(_ onValueChanged: @escaping ValueChangedAction) {
        if refreshControl == nil {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(
                   self,
                   action: #selector(self.onValueChangedAction),
                   for: .valueChanged
               )
            self.refreshControl = refreshControl
        }
        self.onValueChanged = onValueChanged
    }
    
    @objc private func onValueChangedAction(sender: UIRefreshControl) {
        self.onValueChanged?(sender)
    }
}
