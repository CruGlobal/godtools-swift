//
//  TutorialPagerAnalytics.swift
//  godtools
//
//  Created by Robert Eldredge on 10/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct TutorialPagerAnalytics {
    
    var screenName: String
    var siteSection: String
    var siteSubsection: String
    var continueButtonTappedActionName: String
    var continueButtonTappedData : [String : Any]?
    var videoPlayedActionName: String
    var videoPlayedData: [String : Any]?
}
