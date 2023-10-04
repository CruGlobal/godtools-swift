//
//  LessonListItemDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/3/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct LessonListItemDomainModel: LessonListItemDomainModelInterface {
    
    let appLanguageAvailability: LessonAvailabilityInAppLanguageDomainModel
    let lesson: LessonDomainModel
    let name: LessonNameDomainModel
}

extension LessonListItemDomainModel: Identifiable {
    var id: String {
        return lesson.id
    }
}
