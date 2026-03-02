//
//  View+Animation.swift
//  godtools
//
//  Created by Levi Eggert on 2/25/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

extension View {
    
    private static var animationsDisabled: Bool {
        return GodToolsApp.appLaunchType == .uiTests
    }
    
    public func animateIfEnabled<V>(_ animation: Animation?, value: V) -> some View where V : Equatable {
        return self.animation(Self.animationsDisabled ? nil : animation, value: value)
    }
}
