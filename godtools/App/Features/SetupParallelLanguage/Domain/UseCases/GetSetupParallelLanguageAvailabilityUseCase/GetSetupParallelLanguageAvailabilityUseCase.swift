//
//  GetSetupParallelLanguageAvailabilityUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetSetupParallelLanguageAvailabilityUseCase {
    
    private let launchCountRepository: LaunchCountRepository
    private let setupParallelLanguageViewedRepository: SetupParallelLanguageViewedRepository
    
    init(launchCountRepository: LaunchCountRepository, setupParallelLanguageViewedRepository: SetupParallelLanguageViewedRepository) {
        
        self.launchCountRepository = launchCountRepository
        self.setupParallelLanguageViewedRepository = setupParallelLanguageViewedRepository
    }
    
    func getSetupParallelLanguageIsAvailable() -> SetupParallelLanguageAvailabilityDomainModel {
        
        let launchCount: Int = launchCountRepository.getLaunchCount()
        let setupParallelLanguagedViewed: Bool = setupParallelLanguageViewedRepository.getSetupParallelLanguageViewed()
                
        return SetupParallelLanguageAvailabilityDomainModel(
            isAvailable: launchCount == 1 && !setupParallelLanguagedViewed
        )
    }
}
