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
    private let tappedClosure: (() -> Void)?
    
    init(
        geometry: GeometryProxy,
        title: String,
        accessibility: AccessibilityStrings.Button?,
        tappedClosure: (() -> Void)?
    ) {
        
        self.geometry = geometry
        self.title = title
        self.accessibility = accessibility
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        GTButton(
            style: .blue,
            title: title,
            font: FontLibrary.sfProTextSemibold.font(size: 17),
            width: geometry.size.width - 60,
            height: 50,
            accessibility: accessibility,
            tapped: {
                tappedClosure?()
            }
        )
    }
}
