//
//  AppFeatureDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AppFeatureDiContainer {
    
    let appLanguage: AppLanguageFeatureDiContainer
    let featuredLessons: FeaturedLessonsDiContainer
    let lessonEvaluation: LessonEvaluationFeatureDiContainer
    let lessons: LessonsFeatureDiContainer
    let onboarding: OnboardingDiContainer
    let toolDetails: ToolDetailsFeatureDiContainer
    
    init(appLanguage: AppLanguageFeatureDiContainer, featuredLessons: FeaturedLessonsDiContainer, lessonEvaluation: LessonEvaluationFeatureDiContainer, lessons: LessonsFeatureDiContainer, onboarding: OnboardingDiContainer, toolDetails: ToolDetailsFeatureDiContainer) {
        
        self.appLanguage = appLanguage
        self.featuredLessons = featuredLessons
        self.lessonEvaluation = lessonEvaluation
        self.lessons = lessons
        self.onboarding = onboarding
        self.toolDetails = toolDetails
    }
}
