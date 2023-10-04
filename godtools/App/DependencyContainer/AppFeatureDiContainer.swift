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
    let lessons: LessonsFeatureDiContainer
    
    init(appLanguage: AppLanguageFeatureDiContainer, featuredLessons: FeaturedLessonsDiContainer, lessons: LessonsFeatureDiContainer) {
        
        self.appLanguage = appLanguage
        self.featuredLessons = featuredLessons
        self.lessons = lessons
    }
}
