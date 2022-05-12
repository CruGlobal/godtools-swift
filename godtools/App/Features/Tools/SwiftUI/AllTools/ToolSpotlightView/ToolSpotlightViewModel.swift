//
//  ToolSpotlightViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ToolSpotlightViewModel: BaseToolSpotlightViewModel {
    
    // MARK: - Properties
    
    private let localizationServices: LocalizationServices
    
    // MARK: - Init
    
    init(localizationServices: LocalizationServices) {
        self.localizationServices = localizationServices
        
        let spotlightTitle = localizationServices.stringForMainBundle(key: "allTools.spotlight.title")
        let spotlightSubtitle = localizationServices.stringForMainBundle(key: "allTools.spotlight.description")
        
        super.init(spotlightTitle: spotlightTitle, spotlightSubtitle: spotlightSubtitle)
    }
}
