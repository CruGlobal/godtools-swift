//
//  UserLessonProgressDomainLayerDependencies.swift
//  godtools
//
//  Created by Rachael Skeath on 9/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class UserLessonProgressDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: UserLessonProgressDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: UserLessonProgressDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getResumeLessonProgressStringsUseCase() -> GetResumeLessonProgressStringsUseCase {
        return GetResumeLessonProgressStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getStoreUserLessonProgressUseCase() -> StoreUserLessonProgressUseCase {
        return StoreUserLessonProgressUseCase(
            lessonProgressRepository: core.dataLayer.getUserLessonProgressRepository()
        )
    }
}
