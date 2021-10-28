//
//  TutorialPagerAnalytics.swift
//  godtools
//
//  Created by Robert Eldredge on 10/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct TutorialPagerAnalytics {
    
    let screenName: String
    let siteSection: String
    let siteSubsection: String
    let continueButtonTappedActionName: String
    let continueButtonTappedData : [String : Any]?
    let screenTrackIndexOffset: Int
}
