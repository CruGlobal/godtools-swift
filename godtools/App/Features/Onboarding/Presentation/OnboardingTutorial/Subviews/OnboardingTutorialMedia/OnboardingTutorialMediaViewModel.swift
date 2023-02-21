//
//  OnboardingTutorialMediaViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialMediaViewModel: ObservableObject {
    
    let title: String
    let message: String
    let animationFilename: String
    
    init(title: String, message: String, animationFilename: String) {
        
        self.title = title
        self.message = message
        self.animationFilename = animationFilename
    }
}
