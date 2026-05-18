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
    
    init(core: AppCoreDiContainer) {
        
        dataLayer = UserLessonProgressDataLayerDependencies(coreDataLayer: core.dataLayer)
        domainLayer = UserLessonProgressDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
