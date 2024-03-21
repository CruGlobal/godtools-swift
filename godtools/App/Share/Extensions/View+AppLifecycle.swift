//
//  View+AppLifecycle.swift
//  godtools
//
//  Created by Rachael Skeath on 1/25/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import SwiftUI

extension View {
    
    // NOTE: SwiftUI supports lifecycle observation through `ScenePhase` (https://developer.apple.com/documentation/swiftui/scenephase),
    // but ScenePhase seems to require being propagated from the App's ContentView in order to work, and not through UIViewController. (https://stackoverflow.com/questions/72620039/trigger-an-action-when-scenephase-changes-in-a-sheet)
    
    // TODO: - when we completely transition from UIKit to SwiftUI, reinvestigate using `ScenePhase` for background/foreground observation rather than listening for UIApplication notifications.
    
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
