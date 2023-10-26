//
//  AccessibilityScreenElementView.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

// NOTE: Place within a view that makes up a screen.  Typically a GeometryReader or VStack etc.
// Having accessibilityIdentifier on the top level GeometryReader was somehow causing an issue when querying for the choose app language button in OnboardingTutorialView.
// Also keeping the accessibility on a TextElement solved issues with querying.  Tried placing on a Group and ZStack but was unable to find the element. ~Levi

struct AccessibilityScreenElementView: View {
    
    private let screenAccessibility: AccessibilityStrings.Screen
    
    init(screenAccessibility: AccessibilityStrings.Screen) {
        
        self.screenAccessibility = screenAccessibility
    }
    
    var body: some View {
        ZStack {
            Text("")
                .accessibilityIdentifier(screenAccessibility.id)
        }
    }
}
