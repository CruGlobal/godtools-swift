//
//  FeaturedLessonDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct FeaturedLessonDomainModel: LessonListItemDomainModelInterface {
    
    let appLanguageAvailability: LessonAvailabilityInAppLanguageDomainModel
    let lesson: LessonDomainModel
    let name: LessonNameDomainModel
}

extension FeaturedLessonDomainModel: Identifiable {
    var id: String {
        return lesson.id
    }
}
