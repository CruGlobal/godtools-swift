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
        
    private let navigationBar: AppNavigationBar?
    
    init(rootView: Content, navigationBar: AppNavigationBar?) {
        
        self.navigationBar = navigationBar
        
        super.init(rootView: rootView)
        
        navigationBar?.configure(viewController: self)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
