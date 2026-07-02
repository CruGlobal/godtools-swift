//
//  GetTutorialIsAvailableUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/18/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetTutorialIsAvailableUseCase {
    
    private let getTutorialType: GetTutorialType
    
    init(getTutorialType: GetTutorialType) {
        
        self.getTutorialType = getTutorialType
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> Bool {
        
        return getTutorialType.getType(appLanguage: appLanguage) != .noTutorial
    }
}
