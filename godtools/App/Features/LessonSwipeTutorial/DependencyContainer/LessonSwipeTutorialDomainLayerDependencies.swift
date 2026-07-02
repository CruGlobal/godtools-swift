//
//  LessonSwipeTutorialDomainLayerDependencies.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class LessonSwipeTutorialDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: LessonSwipeTutorialDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: LessonSwipeTutorialDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getLessonSwipeTutorialStringsUseCase() -> GetLessonSwipeTutorialStringsUseCase {
        return GetLessonSwipeTutorialStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getShouldShowLessonSwipeTutorialUseCase() -> ShouldShowLessonSwipeTutorialUseCase {
        return ShouldShowLessonSwipeTutorialUseCase(
            lessonSwipeTutorialViewedRepo: dataLayer.getLessonSwipeTutorialViewedRepository()
        )
    }
    
    func getTrackViewedLessonSwipeTutorialUseCase() -> TrackViewedLessonSwipeTutorialUseCase {
        return TrackViewedLessonSwipeTutorialUseCase(
            lessonSwipeTutorialViewedRepository: dataLayer.getLessonSwipeTutorialViewedRepository()
        )
    }
}
