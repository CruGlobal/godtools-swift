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
    let lessonFilter: LessonFilterDiContainer
    let lessons: LessonsFeatureDiContainer
    let lessonProgress: UserLessonProgressDiContainer
    let lessonSwipeTutorial: LessonSwipeTutorialDiContainer
    let onboarding: OnboardingDiContainer
    let optInNotification: OptInNotificationDiContainer
    let persistFavoritedToolLanguageSettings: PersistUserToolLanguageSettingsDiContainer
    let shareables: ShareablesDiContainer
    let shareGodTools: ShareGodToolsDiContainer
    let spotlightTools: SpotlightToolsDiContainer
    let toolDetails: ToolDetailsFeatureDiContainer
    let toolScreenShare: ToolScreenShareFeatureDiContainer
    let toolSettings: ToolSettingsDiContainer
    let toolsFilter: ToolsFilterFeatureDiContainer
    let toolShortcutLinks: ToolShortcutLinksDiContainer
    let tutorial: TutorialFeatureDiContainer
    
    init(account: AccountDiContainer, appLanguage: AppLanguageFeatureDiContainer, dashboard: DashboardDiContainer, downloadToolProgress: DownloadToolProgressFeatureDiContainer, favorites: FavoritesDiContainer, featuredLessons: FeaturedLessonsDiContainer, globalActivity: GlobalActivityDiContainer, learnToShareTool: LearnToShareToolDiContainer, lessonEvaluation: LessonEvaluationFeatureDiContainer, lessonFilter: LessonFilterDiContainer, lessons: LessonsFeatureDiContainer, lessonProgress: UserLessonProgressDiContainer, lessonSwipeTutorial: LessonSwipeTutorialDiContainer, onboarding: OnboardingDiContainer, optInNotification: OptInNotificationDiContainer, persistFavoritedToolLanguageSettings: PersistUserToolLanguageSettingsDiContainer, shareables: ShareablesDiContainer, shareGodTools: ShareGodToolsDiContainer, spotlightTools: SpotlightToolsDiContainer, toolDetails: ToolDetailsFeatureDiContainer, toolScreenShare: ToolScreenShareFeatureDiContainer, toolSettings: ToolSettingsDiContainer, toolsFilter: ToolsFilterFeatureDiContainer, toolShortcutLinks: ToolShortcutLinksDiContainer, tutorial: TutorialFeatureDiContainer) {
        
        self.account = account
        self.appLanguage = appLanguage
        self.dashboard = dashboard
        self.downloadToolProgress = downloadToolProgress
        self.favorites = favorites
        self.featuredLessons = featuredLessons
        self.globalActivity = globalActivity
        self.learnToShareTool = learnToShareTool
        self.lessonEvaluation = lessonEvaluation
        self.lessonFilter = lessonFilter
        self.lessons = lessons
        self.lessonProgress = lessonProgress
        self.lessonSwipeTutorial = lessonSwipeTutorial
        self.onboarding = onboarding
        self.optInNotification = optInNotification
        self.persistFavoritedToolLanguageSettings = persistFavoritedToolLanguageSettings
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
