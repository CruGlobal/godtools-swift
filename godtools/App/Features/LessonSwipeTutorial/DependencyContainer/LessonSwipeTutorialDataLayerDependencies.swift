//
//  LessonSwipeTutorialDataLayerDependencies.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class LessonSwipeTutorialDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    func getLessonSwipeTutorialViewedRepository() -> LessonSwipeTutorialViewedRepository {
        return LessonSwipeTutorialViewedRepository(
            cache: LessonSwipeTutorialViewedUserDefaultsCache(
                userDefaultsCache: coreDataLayer.getUserDefaultsCache()
            )
        )
    }
    
    // MARK: - Domain Interface
    
    func getLessonSwipeTutorialInterfaceStringsRepositoryInterface() -> GetLessonSwipeTutorialInterfaceStringsRepositoryInterface {
        return GetLessonSwipeTutorialInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getShouldShowLessonSwipeTutorialRepositoryInterface() -> ShouldShowLessonSwipeTutorialRepositoryInterface {
        return ShouldShowLessonSwipeTutorialRepository(
            lessonSwipeTutorialViewedRepo: getLessonSwipeTutorialViewedRepository()
        )
    }
    
    func getTrackViewedLessonSwipeTutorialRepositoryInterface() -> TrackViewedLessonSwipeTutorialRepositoryInterface {
        return TrackViewedLessonSwipeTutorialRepository(
            lessonSwipeTutorialViewedRepository: getLessonSwipeTutorialViewedRepository()
        )
    }
}
