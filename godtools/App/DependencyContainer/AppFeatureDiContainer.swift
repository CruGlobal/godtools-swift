//
//  AppFeatureDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AppFeatureDiContainer {
    
    let accountCreation: AccountCreationFeatureDiContainer
    let appLanguage: AppLanguageFeatureDiContainer
    let dashboard: DashboardDiContainer
    let downloadToolProgress: DownloadToolProgressFeatureDiContainer
    let favorites: FavoritesDiContainer
    let featuredLessons: FeaturedLessonsDiContainer
    let learnToShareTool: LearnToShareToolDiContainer
    let lessonEvaluation: LessonEvaluationFeatureDiContainer
    let lessons: LessonsFeatureDiContainer
    let onboarding: OnboardingDiContainer
    let shareables: ShareablesDiContainer
    let spotlightTools: SpotlightToolsDiContainer
    let toolDetails: ToolDetailsFeatureDiContainer
    let toolScreenShare: ToolScreenShareFeatureDiContainer
    let toolSettings: ToolSettingsDiContainer
    let toolsFilter: ToolsFilterFeatureDiContainer
    let toolShortcutLinks: ToolShortcutLinksDiContainer
    let tutorial: TutorialFeatureDiContainer
    
    init(accountCreation: AccountCreationFeatureDiContainer, appLanguage: AppLanguageFeatureDiContainer, dashboard: DashboardDiContainer, downloadToolProgress: DownloadToolProgressFeatureDiContainer, favorites: FavoritesDiContainer, featuredLessons: FeaturedLessonsDiContainer, learnToShareTool: LearnToShareToolDiContainer, lessonEvaluation: LessonEvaluationFeatureDiContainer, lessons: LessonsFeatureDiContainer, onboarding: OnboardingDiContainer, shareables: ShareablesDiContainer, spotlightTools: SpotlightToolsDiContainer, toolDetails: ToolDetailsFeatureDiContainer, toolScreenShare: ToolScreenShareFeatureDiContainer, toolSettings: ToolSettingsDiContainer, toolsFilter: ToolsFilterFeatureDiContainer, toolShortcutLinks: ToolShortcutLinksDiContainer, tutorial: TutorialFeatureDiContainer) {
        
        self.accountCreation = accountCreation
        self.appLanguage = appLanguage
        self.dashboard = dashboard
        self.downloadToolProgress = downloadToolProgress
        self.favorites = favorites
        self.featuredLessons = featuredLessons
        self.learnToShareTool = learnToShareTool
        self.lessonEvaluation = lessonEvaluation
        self.lessons = lessons
        self.onboarding = onboarding
        self.shareables = shareables
        self.spotlightTools = spotlightTools
        self.toolDetails = toolDetails
        self.toolScreenShare = toolScreenShare
        self.toolSettings = toolSettings
        self.toolsFilter = toolsFilter
        self.toolShortcutLinks = toolShortcutLinks
        self.tutorial = tutorial
    }
}
