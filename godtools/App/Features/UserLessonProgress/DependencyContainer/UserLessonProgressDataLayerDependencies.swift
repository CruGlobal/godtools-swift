//
//  UserLessonProgressDataLayerDependencies.swift
//  godtools
//
//  Created by Rachael Skeath on 9/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class UserLessonProgressDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getUserLessonProgressRepositoryInterface() -> GetUserLessonProgressRepositoryInterface {
        return GetUserLessonProgressRepository(
            userLessonProgressRepository: coreDataLayer.getUserLessonProgressRepository()
        )
    }
    
    func getStoreUserLessonProgressRepositoryInterface() -> StoreUserLessonProgressRepositoryInterface {
        return StoreUserLessonProgressRepository(
            lessonProgressRepository: coreDataLayer.getUserLessonProgressRepository()
        )
    }
}
