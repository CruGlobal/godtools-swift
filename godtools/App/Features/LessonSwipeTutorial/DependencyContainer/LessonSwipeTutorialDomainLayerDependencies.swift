//
//  LessonSwipeTutorialDomainLayerDependencies.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class LessonSwipeTutorialDomainLayerDependencies {
    
    private let dataLayer: LessonSwipeTutorialDataLayerDependencies
    
    init(dataLayer: LessonSwipeTutorialDataLayerDependencies) {
        self.dataLayer = dataLayer
    }
    
    func getLessonSwipeTutorialInterfaceStringsUseCase() -> GetLessonSwipeTutorialInterfaceStringsUseCase {
        return GetLessonSwipeTutorialInterfaceStringsUseCase(
            getLessonSwipeTutorialInterfaceStringsRepo: dataLayer.getLessonSwipeTutorialInterfaceStringsRepositoryInterface()
        )
    }
    
    func getShouldShowLessonSwipeTutorialUseCase() -> ShouldShowLessonSwipeTutorialUseCase {
        return ShouldShowLessonSwipeTutorialUseCase(
            shouldShowLessonSwipeTutorialRepo: dataLayer.getShouldShowLessonSwipeTutorialRepositoryInterface()
        )
    }
    
    func getTrackViewedLessonSwipeTutorialUseCase() -> TrackViewedLessonSwipeTutorialUseCase {
        return TrackViewedLessonSwipeTutorialUseCase(
            trackViewedLessonSwipeTutorialRepo: dataLayer.getTrackViewedLessonSwipeTutorialRepositoryInterface()
        )
    }
}
