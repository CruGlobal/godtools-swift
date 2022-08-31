//
//  TrackScreenModel.swift
//  godtools
//
//  Created by Robert Eldredge on 6/3/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct TrackScreenModel {
    
    let screenName: String
    let siteSection: String
    let siteSubSection: String
    let contentLanguage: String? // TODO: This optional should be removed in GT-1580 to wrap up Epic Analytics Content Language. ~Levi
    let secondaryContentLanguage: String?
    
    init(screenName: String, siteSection: String, siteSubSection: String, contentLanguage: String? = nil, secondaryContentLanguage: String? = nil) {
        
        // TODO: This init should be removed in GT-1580 to wrap up Epic Analytics Content Language. ~Levi
        
        self.screenName = screenName
        self.siteSection = siteSection
        self.siteSubSection = siteSubSection
        self.contentLanguage = contentLanguage
        self.secondaryContentLanguage = secondaryContentLanguage
    }
}
