//
//  UserLessonProgressDiContainer.swift
//  godtools
//
//  Created by Rachael Skeath on 9/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

@MainActor
final class UserLessonProgressDiContainer {
    
    let dataLayer: UserLessonProgressDataLayerDependencies
    let domainLayer: UserLessonProgressDomainLayerDependencies
    
    init(dataLayer: UserLessonProgressDataLayerDependencies, domainLayer: UserLessonProgressDomainLayerDependencies) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
