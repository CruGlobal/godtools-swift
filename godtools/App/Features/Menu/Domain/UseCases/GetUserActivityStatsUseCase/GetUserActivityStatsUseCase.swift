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
    
    func getUserActivityStats(from userActivity: UserActivity) -> [UserActivityStatDomainModel] {
        
        let toolOpensStat = UserActivityStatDomainModel(
            iconImageName: "tool-opens",
            text: "Tool opens",
            textColor: Color(red: 5 / 255, green: 105 / 255, blue: 155 / 255),
            value: String(userActivity.toolOpens)
        )
        
        let lessonCompletionsStat = UserActivityStatDomainModel(
            iconImageName: "lesson-completions",
            text: "Lesson completions",
            textColor: Color(red: 55 / 255, green: 167 / 255, blue: 160 / 255),
            value: String(userActivity.lessonCompletions)
        )
        
        let screenSharesStat = UserActivityStatDomainModel(
            iconImageName: "screen-shares",
            text: "Screen shares",
            textColor: Color(red: 229 / 255, green: 91 / 255, blue: 54 / 255),
            value: String(userActivity.screenShares)
        )
        
        let linksSharedStat = UserActivityStatDomainModel(
            iconImageName: "links-shared",
            text: "Links shared",
            textColor: Color(red: 47 / 255, green: 54 / 255, blue: 118 / 255),
            value: String(userActivity.linksShared)
        )
        
        let languagesUsedStat = UserActivityStatDomainModel(
            iconImageName: "languages-used",
            text: "Languages used",
            textColor: Color(red: 110 / 255, green: 220 / 255, blue: 80 / 255),
            value: String(userActivity.languagesUsed)
        )
        
        let sessionsStat = UserActivityStatDomainModel(
            iconImageName: "sessions",
            text: "Sessions",
            textColor: Color(red: 224 / 255, green: 206 / 255, blue: 38 / 255),
            value: String(userActivity.sessions)
        )
        
        return [toolOpensStat, lessonCompletionsStat, screenSharesStat, linksSharedStat, languagesUsedStat, sessionsStat]
    }
}
