//
//  OnboardingQuickStartItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class OnboardingQuickStartItemViewModel: ObservableObject {
    
    let title: String
    let actionTitle: String
    
    init(item: OnboardingQuickStartItemDomainModel) {
        
        title = item.title
        actionTitle = item.actionTitle
    }
}
