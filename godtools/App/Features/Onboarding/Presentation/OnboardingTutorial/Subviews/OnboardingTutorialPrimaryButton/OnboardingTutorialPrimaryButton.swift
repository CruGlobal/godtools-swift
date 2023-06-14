//
//  OnboardingTutorialPrimaryButton.swift
//  godtools
//
//  Created by Levi Eggert on 3/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct OnboardingTutorialPrimaryButton: View {
    
    let geometry: GeometryProxy
    let title: String
    let action: () -> Void
    
    var body: some View {
        
        GTBlueButton(title: title, font: FontLibrary.sfProTextSemibold.font(size: 17), width: geometry.size.width - 60, height: 50, highlightsTitleOnTap: false) {
            
            action()
        }
    }
}
