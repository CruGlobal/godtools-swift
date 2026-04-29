//
//  UserLessonProgressDiContainer.swift
//  godtools
//
//  Created by Rachael Skeath on 9/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class UserLessonProgressDiContainer {
    
    let dataLayer: UserLessonProgressDataLayerDependencies
    let domainLayer: UserLessonProgressDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = UserLessonProgressDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = UserLessonProgressDomainLayerDependencies(dataLayer: dataLayer, coreDataLayer: coreDataLayer)
    }
}
