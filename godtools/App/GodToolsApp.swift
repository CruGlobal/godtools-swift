//
//  GodToolsApp.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

@main
struct GodToolsApp: App {
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            appDelegate.appFlow
        }
    }
}
