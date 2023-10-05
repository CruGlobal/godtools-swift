//
//  AppHostingController.swift
//  godtools
//
//  Created by Levi Eggert on 10/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class AppHostingController<Content: View>: UIHostingController<Content> {
        
    private var navBarItems: NavBarItems?
    
    init(rootView: Content, navigationBar: AppNavigationBar?) {
        
        super.init(rootView: rootView)
        
        if let navigationBar = navigationBar {
            navBarItems = NavBarItems(viewController: self, leadingItems: navigationBar.leadingItems, trailingItems: navigationBar.trailingItems)
        }
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
