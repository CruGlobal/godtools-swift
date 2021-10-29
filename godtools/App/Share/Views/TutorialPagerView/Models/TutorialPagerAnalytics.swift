//
//  TutorialPagerAnalytics.swift
//  godtools
//
//  Created by Robert Eldredge on 10/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class TutorialPagerAnalytics {
    
    let siteSection: String
    let siteSubsection: String
    let continueButtonTappedActionName: String
    let continueButtonTappedData : [String : Any]?
    
    private let screenName: String
    private let screenTrackIndexOffset: Int
    
    required init(screenName: String, siteSection: String, siteSubsection: String, continueButtonTappedActionName: String, continueButtonTappedData: [String: Any]?, screenTrackIndexOffset: Int) {
        
        self.screenName = screenName
        self.siteSection = siteSection
        self.siteSubsection = siteSubsection
        self.continueButtonTappedActionName = continueButtonTappedActionName
        self.continueButtonTappedData = continueButtonTappedData
        self.screenTrackIndexOffset = screenTrackIndexOffset
    }
    
    func analyticsScreenName(page: Int) -> String {
        
        if screenName.isEmpty {
            return ""
        }
        
        return "\(screenName)-\(page + screenTrackIndexOffset)"
    }
}
