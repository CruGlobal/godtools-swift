//
//  UserLessonProgressDataLayerDependencies.swift
//  godtools
//
//  Created by Rachael Skeath on 9/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class UserLessonProgressDataLayerDependencies {
    
    private let coreDataLayer: CoreDataLayerDependenciesInterface
    
    init(coreDataLayer: CoreDataLayerDependenciesInterface) {
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getResumeLessonProgressModalInterfaceStringsRepositoryInterface() -> GetResumeLessonProgressModalInterfaceStringsRepositoryInterface {
        return GetResumeLessonProgressModalInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getStoreUserLessonProgressRepositoryInterface() -> StoreUserLessonProgressRepositoryInterface {
        return StoreUserLessonProgressRepository(
            lessonProgressRepository: coreDataLayer.getUserLessonProgressRepository()
        )
    }
}
