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
            text: localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.Account.Activity.toolOpens.rawValue),
            textColor: Color.getColorWithRGB(red: 5, green: 105, blue: 155, opacity: 1),
            value: String(userActivity.toolOpens)
        )
        
        let lessonCompletionsStat = UserActivityStatDomainModel(
            iconImageName: ImageCatalog.userActivityLessonCompletions.name,
            text: localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.Account.Activity.lessonCompletions.rawValue),
            textColor: Color.getColorWithRGB(red: 55, green: 167, blue: 160, opacity: 1),
            value: String(userActivity.lessonCompletions)
        )
        
        let screenSharesStat = UserActivityStatDomainModel(
            iconImageName: ImageCatalog.userActivityScreenShares.name,
            text: localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.Account.Activity.screenShares.rawValue),
            textColor: Color.getColorWithRGB(red: 229, green: 91, blue: 54, opacity: 1),
            value: String(userActivity.screenShares)
        )
        
        let linksSharedStat = UserActivityStatDomainModel(
            iconImageName: ImageCatalog.userActivityLinksShared.name,
            text: localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.Account.Activity.linksShared.rawValue),
            textColor: Color.getColorWithRGB(red: 47, green: 54, blue: 118, opacity: 1),
            value: String(userActivity.linksShared)
        )
        
        let languagesUsedStat = UserActivityStatDomainModel(
            iconImageName: ImageCatalog.userActivityLanguagesUsed.name,
            text: localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.Account.Activity.languagesUsed.rawValue),
            textColor: Color.getColorWithRGB(red: 110, green: 220, blue: 80, opacity: 1),
            value: String(userActivity.languagesUsed)
        )

        let sessionsStat = UserActivityStatDomainModel(
            iconImageName: ImageCatalog.userActivitySessions.name,
            text: localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.Account.Activity.sessions.rawValue),
            textColor: Color.getColorWithRGB(red: 224, green: 206, blue: 38, opacity: 1),
            value: String(userActivity.sessions)
        )
        
        return [toolOpensStat, lessonCompletionsStat, screenSharesStat, linksSharedStat, languagesUsedStat, sessionsStat]
    }
}
