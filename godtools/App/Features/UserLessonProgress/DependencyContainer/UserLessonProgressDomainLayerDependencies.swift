//
//  UserLessonProgressDomainLayerDependencies.swift
//  godtools
//
//  Created by Rachael Skeath on 9/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class UserLessonProgressDomainLayerDependencies {
    
    private let dataLayer: UserLessonProgressDataLayerDependencies
    private let coreDataLayer: AppDataLayerDependencies
    
    init(dataLayer: UserLessonProgressDataLayerDependencies, coreDataLayer: AppDataLayerDependencies) {
        self.dataLayer = dataLayer
        self.coreDataLayer = coreDataLayer
    }
    
    func getStoreUserLessonProgressUseCase() -> StoreUserLessonProgressUseCase {
        return StoreUserLessonProgressUseCase(
            storeLessonProgressRepository: dataLayer.getStoreUserLessonProgressRepositoryInterface()
        )
    }
}
