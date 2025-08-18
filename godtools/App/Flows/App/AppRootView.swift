//
//  AppRootView.swift
//  godtools
//
//  Created by Levi Eggert on 6/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI
import UIKit

struct AppRootView: UIViewControllerRepresentable {
    
    private let appRootController: AppRootController
    
    init(appRootController: AppRootController) {
        self.appRootController = appRootController
    }
    
    func makeUIViewController(context: Context) -> AppRootController {
        return appRootController
    }
    
    func updateUIViewController(_ uiViewController: AppRootController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
}
