//
//  View+AppLifecycle.swift
//  godtools
//
//  Created by Rachael Skeath on 1/25/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import SwiftUI

extension View {
    
    func onAppBackgrounded(_ closure: @escaping () -> Void) -> some View {
        self.onReceive(
            NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
            perform: { _ in closure() }
        )
    }
    
    func onAppForegrounded(_ closure: @escaping () -> Void) -> some View {
        self.onReceive(
            NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification),
            perform: { _ in closure() }
        )
    }
}
