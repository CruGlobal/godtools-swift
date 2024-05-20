//
//  AppFeatureDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AppFeatureDiContainer {
    
    let account: AccountDiContainer
    let appLanguage: AppLanguageFeatureDiContainer
    let dashboard: DashboardDiContainer
    let downloadToolProgress: DownloadToolProgressFeatureDiContainer
    let favorites: FavoritesDiContainer
    let featuredLessons: FeaturedLessonsDiContainer
    let globalActivity: GlobalActivityDiContainer
    let learnToShareTool: LearnToShareToolDiContainer
    let lessonEvaluation: LessonEvaluationFeatureDiContainer
    let lessons: LessonsFeatureDiContainer
    let onboarding: OnboardingDiContainer
    let shareables: ShareablesDiContainer
    let shareGodTools: ShareGodToolsDiContainer
    let spotlightTools: SpotlightToolsDiContainer
    let toolDetails: ToolDetailsFeatureDiContainer
    let toolScreenShare: ToolScreenShareFeatureDiContainer
    let toolSettings: ToolSettingsDiContainer
    let toolsFilter: ToolsFilterFeatureDiContainer
    let toolShortcutLinks: ToolShortcutLinksDiContainer
    let tutorial: TutorialFeatureDiContainer
    
    init(account: AccountDiContainer, appLanguage: AppLanguageFeatureDiContainer, dashboard: DashboardDiContainer, downloadToolProgress: DownloadToolProgressFeatureDiContainer, favorites: FavoritesDiContainer, featuredLessons: FeaturedLessonsDiContainer, globalActivity: GlobalActivityDiContainer, learnToShareTool: LearnToShareToolDiContainer, lessonEvaluation: LessonEvaluationFeatureDiContainer, lessons: LessonsFeatureDiContainer, onboarding: OnboardingDiContainer, shareables: ShareablesDiContainer, shareGodTools: ShareGodToolsDiContainer, spotlightTools: SpotlightToolsDiContainer, toolDetails: ToolDetailsFeatureDiContainer, toolScreenShare: ToolScreenShareFeatureDiContainer, toolSettings: ToolSettingsDiContainer, toolsFilter: ToolsFilterFeatureDiContainer, toolShortcutLinks: ToolShortcutLinksDiContainer, tutorial: TutorialFeatureDiContainer) {
        
        self.account = account
        self.appLanguage = appLanguage
        self.dashboard = dashboard
        self.downloadToolProgress = downloadToolProgress
        self.favorites = favorites
        self.featuredLessons = featuredLessons
        self.globalActivity = globalActivity
        self.learnToShareTool = learnToShareTool
        self.lessonEvaluation = lessonEvaluation
        self.lessons = lessons
        self.onboarding = onboarding
        self.shareables = shareables
        self.shareGodTools = shareGodTools
        self.spotlightTools = spotlightTools
        self.toolDetails = toolDetails
        self.toolScreenShare = toolScreenShare
        self.toolSettings = toolSettings
        self.toolsFilter = toolsFilter
        self.toolShortcutLinks = toolShortcutLinks
        self.tutorial = tutorial
    }
}
