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
    private let getTranslatedNumberCount: GetTranslatedNumberCount
    
    init(localizationServices: LocalizationServices, getTranslatedNumberCount: GetTranslatedNumberCount) {
        
        self.localizationServices = localizationServices
        self.getTranslatedNumberCount = getTranslatedNumberCount
    }
    
    func getUserActivityStats(from userActivity: UserActivity, translatedInAppLanguage: AppLanguageDomainModel) -> [UserActivityStatDomainModel] {
        
        let toolOpensStat = UserActivityStatDomainModel(
            iconImageName: ImageCatalog.userActivityToolOpens.name,
            text: getUserActivityText(stringKey: MenuStringKeys.Account.Activity.toolOpens.rawValue, activityCount: userActivity.toolOpens, translatedInAppLanguage: translatedInAppLanguage),
            textColor: Color.getColorWithRGB(red: 5, green: 105, blue: 155, opacity: 1),
            value: getUserActivityFormattedCount(activityCount: userActivity.toolOpens, translatedInAppLanguage: translatedInAppLanguage)
        )
        
        let lessonCompletionsStat = UserActivityStatDomainModel(
            iconImageName: ImageCatalog.userActivityLessonCompletions.name,
            text: getUserActivityText(stringKey: MenuStringKeys.Account.Activity.lessonCompletions.rawValue, activityCount: userActivity.lessonCompletions, translatedInAppLanguage: translatedInAppLanguage),
            textColor: Color.getColorWithRGB(red: 55, green: 167, blue: 160, opacity: 1),
            value: getUserActivityFormattedCount(activityCount: userActivity.lessonCompletions, translatedInAppLanguage: translatedInAppLanguage)
        )
        
        let screenSharesStat = UserActivityStatDomainModel(
            iconImageName: ImageCatalog.userActivityScreenShares.name,
            text: getUserActivityText(stringKey: MenuStringKeys.Account.Activity.screenShares.rawValue, activityCount: userActivity.screenShares, translatedInAppLanguage: translatedInAppLanguage),
            textColor: Color.getColorWithRGB(red: 229, green: 91, blue: 54, opacity: 1),
            value: getUserActivityFormattedCount(activityCount: userActivity.screenShares, translatedInAppLanguage: translatedInAppLanguage)
        )
        
        let linksSharedStat = UserActivityStatDomainModel(
            iconImageName: ImageCatalog.userActivityLinksShared.name,
            text: getUserActivityText(stringKey: MenuStringKeys.Account.Activity.linksShared.rawValue, activityCount: userActivity.linksShared, translatedInAppLanguage: translatedInAppLanguage),
            textColor: Color.getColorWithRGB(red: 47, green: 54, blue: 118, opacity: 1),
            value: getUserActivityFormattedCount(activityCount: userActivity.linksShared, translatedInAppLanguage: translatedInAppLanguage)
        )
        
        let languagesUsedStat = UserActivityStatDomainModel(
            iconImageName: ImageCatalog.userActivityLanguagesUsed.name,
            text: getUserActivityText(stringKey: MenuStringKeys.Account.Activity.languagesUsed.rawValue, activityCount: userActivity.languagesUsed, translatedInAppLanguage: translatedInAppLanguage),
            textColor: Color.getColorWithRGB(red: 110, green: 220, blue: 80, opacity: 1),
            value: getUserActivityFormattedCount(activityCount: userActivity.languagesUsed, translatedInAppLanguage: translatedInAppLanguage)
        )
        
        let sessionsStat = UserActivityStatDomainModel(
            iconImageName: ImageCatalog.userActivitySessions.name,
            text: getUserActivityText(stringKey: MenuStringKeys.Account.Activity.sessions.rawValue, activityCount: userActivity.sessions, translatedInAppLanguage: translatedInAppLanguage),
            textColor: Color.getColorWithRGB(red: 224, green: 206, blue: 38, opacity: 1),
            value: getUserActivityFormattedCount(activityCount: userActivity.sessions, translatedInAppLanguage: translatedInAppLanguage)
        )
        
        return [toolOpensStat, lessonCompletionsStat, screenSharesStat, linksSharedStat, languagesUsedStat, sessionsStat]
    }
    
    private func getUserActivityText(stringKey: String, activityCount: Int32, translatedInAppLanguage: AppLanguageDomainModel) -> String {
        
        let formatString = localizationServices.stringForLocaleElseEnglish(
            localeIdentifier: translatedInAppLanguage.localeId,
            key: stringKey,
            fileType: .stringsdict
        )
        
        return String.localizedStringWithFormat(formatString, activityCount)
    }
    
    private func getUserActivityFormattedCount(activityCount: Int32, translatedInAppLanguage: AppLanguageDomainModel) -> String {
                        
        return getTranslatedNumberCount.getTranslatedCount(count: Int(activityCount), translateInLanguage: translatedInAppLanguage)
    }
}
