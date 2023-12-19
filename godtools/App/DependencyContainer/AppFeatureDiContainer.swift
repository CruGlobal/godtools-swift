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
    let downloadToolProgress: DownloadToolProgressFeatureDiContainer
    let featuredLessons: FeaturedLessonsDiContainer
    let learnToShareTool: LearnToShareToolDiContainer
    let lessonEvaluation: LessonEvaluationFeatureDiContainer
    let lessons: LessonsFeatureDiContainer
    let onboarding: OnboardingDiContainer
    let sharables: SharablesDiContainer
    let toolDetails: ToolDetailsFeatureDiContainer
    let toolScreenShare: ToolScreenShareFeatureDiContainer
    let toolSettings: ToolSettingsDiContainer
    let toolsFilter: ToolsFilterFeatureDiContainer
    let toolShortcutLinks: ToolShortcutLinksDiContainer
    let tutorial: TutorialFeatureDiContainer
    
    init(accountCreation: AccountCreationFeatureDiContainer, appLanguage: AppLanguageFeatureDiContainer, downloadToolProgress: DownloadToolProgressFeatureDiContainer, featuredLessons: FeaturedLessonsDiContainer, learnToShareTool: LearnToShareToolDiContainer, lessonEvaluation: LessonEvaluationFeatureDiContainer, lessons: LessonsFeatureDiContainer, onboarding: OnboardingDiContainer, sharables: SharablesDiContainer, toolDetails: ToolDetailsFeatureDiContainer, toolScreenShare: ToolScreenShareFeatureDiContainer, toolSettings: ToolSettingsDiContainer, toolsFilter: ToolsFilterFeatureDiContainer, toolShortcutLinks: ToolShortcutLinksDiContainer, tutorial: TutorialFeatureDiContainer) {
        
        self.accountCreation = accountCreation
        self.appLanguage = appLanguage
        self.downloadToolProgress = downloadToolProgress
        self.featuredLessons = featuredLessons
        self.learnToShareTool = learnToShareTool
        self.lessonEvaluation = lessonEvaluation
        self.lessons = lessons
        self.onboarding = onboarding
        self.sharables = sharables
        self.toolDetails = toolDetails
        self.toolScreenShare = toolScreenShare
        self.toolSettings = toolSettings
        self.toolsFilter = toolsFilter
        self.toolShortcutLinks = toolShortcutLinks
        self.tutorial = tutorial
    }
}
