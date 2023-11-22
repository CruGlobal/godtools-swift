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
    let appShortcutItems: AppShortcutItemsDiContainer
    let downloadToolProgress: DownloadToolProgressFeatureDiContainer
    let featuredLessons: FeaturedLessonsDiContainer
    let lessonEvaluation: LessonEvaluationFeatureDiContainer
    let lessons: LessonsFeatureDiContainer
    let onboarding: OnboardingDiContainer
    let toolDetails: ToolDetailsFeatureDiContainer
    let toolScreenShare: ToolScreenShareFeatureDiContainer
    let tutorial: TutorialFeatureDiContainer
    
    init(accountCreation: AccountCreationFeatureDiContainer, appLanguage: AppLanguageFeatureDiContainer, appShortcutItems: AppShortcutItemsDiContainer, downloadToolProgress: DownloadToolProgressFeatureDiContainer, featuredLessons: FeaturedLessonsDiContainer, lessonEvaluation: LessonEvaluationFeatureDiContainer, lessons: LessonsFeatureDiContainer, onboarding: OnboardingDiContainer, toolDetails: ToolDetailsFeatureDiContainer, toolScreenShare: ToolScreenShareFeatureDiContainer, tutorial: TutorialFeatureDiContainer) {
        
        self.accountCreation = accountCreation
        self.appLanguage = appLanguage
        self.appShortcutItems = appShortcutItems
        self.downloadToolProgress = downloadToolProgress
        self.featuredLessons = featuredLessons
        self.lessonEvaluation = lessonEvaluation
        self.lessons = lessons
        self.onboarding = onboarding
        self.toolDetails = toolDetails
        self.toolScreenShare = toolScreenShare
        self.tutorial = tutorial
    }
}
