//
//  OnboardingQuickStartLinkDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct OnboardingQuickStartLinkDomainModel {
    
    let title: String
    let actionTitle: String
    let analyticsEventActionName: String
    let linkType: OnboardingQuickStartLinkTypeDomainModel
}

extension OnboardingQuickStartLinkDomainModel: Identifiable {
    
    var id: String {
        return title
    }
}
