//
//  GetShouldShowLanguageSettingsBarButtonUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 10/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetShouldShowLanguageSettingsBarButtonUseCase {
    
    func getShouldShowLanguageSettingsBarButton(for tab: DashboardTabTypeDomainModel) -> Bool {
        
        switch tab {
        case .favorites, .tools:
            return true
        case .lessons:
            return false
        }
    }
}
