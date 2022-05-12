//
//  BaseToolSpotlightViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class BaseToolSpotlightViewModel: NSObject, ObservableObject {
    
    let spotlightTitle: String
    let spotlightSubtitle: String
    
    init(spotlightTitle: String, spotlightSubtitle: String) {
        self.spotlightTitle = spotlightTitle
        self.spotlightSubtitle = spotlightSubtitle
        
        super.init()
    }
}
