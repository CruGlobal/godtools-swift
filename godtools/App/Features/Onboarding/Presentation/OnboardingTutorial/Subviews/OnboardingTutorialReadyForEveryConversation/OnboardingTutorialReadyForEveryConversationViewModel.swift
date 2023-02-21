//
//  OnboardingTutorialReadyForEveryConversationViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialReadyForEveryConversationViewModel: ObservableObject {
    
    let title: String
    let watchVideoButtonTitle: String
    
    init(title: String, watchVideoButtonTitle: String) {
        
        self.title = title
        self.watchVideoButtonTitle = watchVideoButtonTitle
    }
}
