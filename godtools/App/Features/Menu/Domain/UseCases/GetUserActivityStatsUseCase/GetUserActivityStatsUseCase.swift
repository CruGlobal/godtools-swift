//
//  GetUserActivityStatsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 3/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser
import SwiftUI

class GetUserActivityStatsUseCase {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getUserActivityStats(from userActivity: UserActivity) -> [UserActivityStatDomainModel] {
        
        let toolOpensStat = UserActivityStatDomainModel(
            iconImageName: ImageCatalog.userActivityToolOpens.name,
            text: localizationServices.stringForMainBundle(key: "account.activity.toolOpens"),
            textColor: Color(red: 5 / 255, green: 105 / 255, blue: 155 / 255),
            value: String(userActivity.toolOpens)
        )
        
        let lessonCompletionsStat = UserActivityStatDomainModel(
            iconImageName: ImageCatalog.userActivityLessonCompletions.name,
            text: localizationServices.stringForMainBundle(key: "account.activity.lessonCompletions"),
            textColor: Color(red: 55 / 255, green: 167 / 255, blue: 160 / 255),
            value: String(userActivity.lessonCompletions)
        )
        
        let screenSharesStat = UserActivityStatDomainModel(
            iconImageName: ImageCatalog.userActivityScreenShares.name,
            text: localizationServices.stringForMainBundle(key: "account.activity.screenShares"),
            textColor: Color(red: 229 / 255, green: 91 / 255, blue: 54 / 255),
            value: String(userActivity.screenShares)
        )
        
        let linksSharedStat = UserActivityStatDomainModel(
            iconImageName: ImageCatalog.userActivityLinksShared.name,
            text: localizationServices.stringForMainBundle(key: "account.activity.linksShared"),
            textColor: Color(red: 47 / 255, green: 54 / 255, blue: 118 / 255),
            value: String(userActivity.linksShared)
        )
        
        let languagesUsedStat = UserActivityStatDomainModel(
            iconImageName: ImageCatalog.userActivityLanguagesUsed.name,
            text: localizationServices.stringForMainBundle(key: "account.activity.languagesUsed"),
            textColor: Color(red: 110 / 255, green: 220 / 255, blue: 80 / 255),
            value: String(userActivity.languagesUsed)
        )
        
        let sessionsStat = UserActivityStatDomainModel(
            iconImageName: ImageCatalog.userActivitySessions.name,
            text: localizationServices.stringForMainBundle(key: "account.activity.sessions"),
            textColor: Color(red: 224 / 255, green: 206 / 255, blue: 38 / 255),
            value: String(userActivity.sessions)
        )
        
        return [toolOpensStat, lessonCompletionsStat, screenSharesStat, linksSharedStat, languagesUsedStat, sessionsStat]
    }
}
