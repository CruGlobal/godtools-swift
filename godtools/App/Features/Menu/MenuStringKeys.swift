//
//  MenuStrings.swift
//  godtools
//
//  Created by Rachael Skeath on 3/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class MenuStringKeys {
    
    enum Account: String {
        case navTitle = "account.navTitle"
        case activityButtonTitle = "account.activity.title"
        case activitySectionTitle = "account.activity.sectionTitle"
        case badgesSectionTitle = "account.badges.sectionTitle"
        
        enum Activity: String {
            case languagesUsed = "account.activity.languagesUsed"
            case lessonCompletions = "account.activity.lessonCompletions"
            case linksShared = "account.activity.linksShared"
            case screenShares = "account.activity.screenShares"
            case sessions = "account.activity.sessions"
            case toolOpens = "account.activity.toolOpens"
        }
        
        case globalActivityButtonTitle = "account.globalActivity.title"
        case globalAnalyticsTitle = "accountActivity.globalAnalytics.header.title"
    }
}
