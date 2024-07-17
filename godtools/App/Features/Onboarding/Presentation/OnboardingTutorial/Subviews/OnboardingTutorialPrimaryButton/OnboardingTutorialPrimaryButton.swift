//
//  OnboardingTutorialPrimaryButton.swift
//  godtools
//
//  Created by Levi Eggert on 3/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct OnboardingTutorialPrimaryButton: View {
    
    private let geometry: GeometryProxy
    private let title: String
    private let accessibility: AccessibilityStrings.Button?
    private let action: (() -> Void)
    
    init(geometry: GeometryProxy, title: String, accessibility: AccessibilityStrings.Button?, action: @escaping (() -> Void)) {
        
        self.geometry = geometry
        self.title = title
        self.accessibility = accessibility
        self.action = action
    }
    
    var body: some View {
        
        GTBlueButton(title: title, font: FontLibrary.sfProTextSemibold.font(size: 17), width: geometry.size.width - 60, height: 50, highlightsTitleOnTap: false, accessibility: accessibility) {
            
            action()
        }
    }
}
